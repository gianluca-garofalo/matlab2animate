load('matlab.mat')

FPS = 20;
T = t(1) - 1/FPS - eps;
X = -7:1e-3:7;
dist = DistFcn( X(X>=0) );

fig = figure( 99 );
clf( fig )
set( fig, 'NumberTitle', 'off', 'MenuBar', 'none', 'Color', [.4314 .4157 .4745] );
txt_col = 'w';
line_col = [0 1 1];
dot_col = [.8 .5 0];

figx = MyAxes( [0.53 0.1 0.4 0.4], txt_col );
axis( [0 x(1) -5 1] ), grid
axis manual
MyLabel( '$\xi_1$', '$\dot \xi_1$', txt_col )
h1 = MyLine( figx, line_col );

gauss = MyAxes( [0.53 0.65 0.4 0.3], txt_col );
axis( [0 x(1) 0 1] ), grid
axis manual
MyLabel( '$\xi_1$', '$e^{-V(\xi_1,\sigma)}$', txt_col )
h2 = MyLine( gauss, line_col );
h3 = animatedline( gauss, 'MarkerFaceColor', dot_col, 'Color', dot_col, 'Marker', 'o' );
an = text( x(1)+0.1, 0.07, '$\leftarrow \xi_1(t)$', 'Interpreter', 'latex', 'Rotation', 45, 'Color', txt_col );

state = MyAxes( [0.07 0.1 0.35 0.4], txt_col );
axis( [-7.5 7.5 -5 5] ), grid
axis manual
MyLabel( '$\xi_1$', '$\sigma$', txt_col )
h4 = MyLine( state, line_col );

m = 7.5;
Y = sqrt( 2*abs( log(k3/k2) )*( X.^2 + sb^2 ) );
hold( state, 'on' )
fill( Y, X, 'r', 'FaceAlpha', 0.1 )
fill( -Y, X, 'r', 'FaceAlpha', 0.1 )
fill( [m Y m -m -Y -m], [-m X m m -X -m], 'b', 'FaceAlpha', 0.1 )

eq = '$V(\xi_1,\sigma) = \frac{\xi_1^2}{2(\bar \sigma^2 + \sigma^2)}$';
MyAnnotation( eq, [.07 .85 1 1], txt_col )
eq = '$\dot \xi_1 = - k_1 e^{-V(\xi_1,\sigma)} \xi_1$';
MyAnnotation( eq, [.07 .7 1 1], txt_col )
eq = '$\dot \sigma = \big( k_3 - k_2 e^{-V(\xi_1,\sigma)} \big) \sigma$';
MyAnnotation( eq, [.07 .6 1 1], txt_col )

opt = matlab2animate( 'make', 'background', 'skip', {'animatedline','text'}, 'bounding_box', [-1.4 -1.1 10.85 6.1] );
opt.make = 'frame';

for k = 1:5000:length(t)
    if t(k)-T>=1/FPS
        s2 = sb^2 + s(k)^2;
        y = exp( -dist/(2*s2) );
        
        addpoints( h1, x(k), dx(k) )
        clearpoints( h2 )
        addpoints( h2, X(X>=0), y )
        clearpoints( h3 )
        addpoints( h3, x(k), 0 )
        set( an, 'Position', [x(k)+0.1, 0.07, 0] );
        addpoints( h4, x(k), s(k) )
        drawnow
        
        matlab2animate( 'skip', {'annotationpane','patch','textboxshape'}, opt );
        T = t(k);
    end
end

hold( 'off' )
matlab2animate( 'make', 'root', 'fps', FPS );
matlab2animate( 'make', 'adjust', 'old', 'draw=black', 'new', 'draw=none' );
if isunix
    !make
end
