function opt = example_2()

init_matlab2animate;
load('example_2.mat')

FPS = 15;
T = t(1) - 1/FPS - eps;
X = -7:1e-3:7;
dist = X(X>=0).^2;

fig = figure( 99 );
clf( fig )
set( fig, 'NumberTitle', 'off', 'MenuBar', 'none', 'Color', 'none' );
line_col = [0 1 1];
dot_col = [.8 .5 0];

figx = axes( 'Position', [0.53 0.1 0.4 0.4], 'Color', 'none' );
xlabel( '$\xi$', 'Interpreter', 'latex' )
ylabel( '$\dot \xi$', 'Interpreter', 'latex' )
h1 = animatedline( figx, 'Color', line_col, 'LineWidth', 1.2 );
axis( [0 x(1) -5 1] ), grid
axis manual

gauss = axes( 'Position', [0.53 0.65 0.4 0.3], 'Color', 'none' );
xlabel( '$\xi$', 'Interpreter', 'latex' )
ylabel( '$e^{-V(\xi,\sigma)}$', 'Interpreter', 'latex' )
h2 = animatedline( gauss, 'Color', line_col, 'LineWidth', 1.2 );
h3 = animatedline( gauss, 'MarkerFaceColor', dot_col, 'Color', dot_col, 'Marker', 'o' );
an = text( x(1)+0.1, 0.07, '$\leftarrow \xi(t)$', 'Interpreter', 'latex', 'Rotation', 45 );
axis( [0 x(1) 0 1] ), grid
axis manual

state = axes( 'Position', [0.07 0.1 0.35 0.4], 'Color', 'none' );
xlabel( '$\xi$', 'Interpreter', 'latex' )
ylabel( '$\sigma$', 'Interpreter', 'latex' )
h4 = animatedline( state, 'Color', line_col, 'LineWidth', 1.2 );
axis( [-7.5 7.5 -5 5] ), grid
axis manual

m = 7.5;
Y = sqrt( 2*abs( log(k3/k2) )*( X.^2 + sb^2 ) );
hold( state, 'on' )
fill( Y, X, 'r', 'FaceAlpha', 0.1 )
fill( -Y, X, 'r', 'FaceAlpha', 0.1 )
fill( [m Y m -m -Y -m], [-m X m m -X -m], 'b', 'FaceAlpha', 0.1 )

eq = '$V(\xi,\sigma) = \frac{\xi^2}{2(\bar \sigma^2 + \sigma^2)}$';
annotation( 'textbox', [.07 .85 1 1], 'String', eq, 'LineStyle', 'none',...
    'Interpreter', 'latex', 'VerticalAlignment', 'bottom', 'FontSize', 12 )
eq = '$\dot \xi = - k_1 e^{-V(\xi,\sigma)} \xi$';
annotation( 'textbox', [.07 .7 1 1], 'String', eq, 'LineStyle', 'none',...
    'Interpreter', 'latex', 'VerticalAlignment', 'bottom', 'FontSize', 12 )
eq = '$\dot \sigma = \big( k_3 - k_2 e^{-V(\xi,\sigma)} \big) \sigma$';
annotation( 'textbox', [.07 .6 1 1], 'String', eq, 'LineStyle', 'none',...
    'Interpreter', 'latex', 'VerticalAlignment', 'bottom', 'FontSize', 12 )

opt = matlab2animate( 'make', 'background', 'skip', {'animatedline','text'} );
opt.make = 'frame';

for k = 1:length(t)
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
close( fig );
matlab2animate( 'make', 'slide', 'fps', FPS );
matlab2animate( 'make', 'adjust', 'old',...
    {'font=\color{white!15!black}'  'draw=black'}, 'new',...
    {'fill=none'                    'draw=none'} );
matlab2animate( 'make', 'adjust', 'old',...
    {'width=0.642\figH,' 'at={(0.738\figH,'  'width=0.543\figH,'}, 'new',...
    {'width=0.62\figH,'  'at={(0.713\figH,'  'width=0.562\figH,'} );
matlab2animate( 'make', 'adjust', 'old',...
    {'at={(0.713\figH,' 'at={(-0.109\figH,' ',0\figH)},'}, 'new',...
    {'at={(1.25\figH,'   'at={(-0.22\figH,' ',-0.2\figH)},'} );
matlab2animate( 'make', 'adjust', 'old',...
    {'\node[right, align=left, rotate=45]'                                              '{$\leftarrow \xi(t)$};'}, 'new',...
    {['\begin{pgfonlayer}{foreground}' newline '\node[right, align=left, rotate=45]']   ['{$\leftarrow \xi(t)$};' newline '\end{pgfonlayer}']} );
matlab2animate( 'make', 'adjust', 'old',...
    '\begin{tikzpicture}', 'new',...
    ['\begin{tikzpicture}' newline '\useasboundingbox (-1.0,-1.9) rectangle (8.8,4.5);'] );
if isunix
    !make
    matlab2animate( 'make', 'html', opt );
    web( [opt.slidename '.html'] )
end
