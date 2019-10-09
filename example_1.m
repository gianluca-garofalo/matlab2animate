function opt = example_1()

fig = figure( 99 );
clf( fig )
set( fig, 'NumberTitle', 'off', 'MenuBar', 'none', 'Color', 'none' );
plot3( 0, 0, 0 ), grid
axis([-3 3 -3 3 0 1])
axis manual
xlabel( 'x1' )
ylabel( 'x2' )
zlabel( 'Probability Density' )
opt = matlab2animate( 'make', 'background', 'skip', {'surface'},...
    'bounding_box', [-1.3 -0.8 5.8 4.4], 'height', '0.3\columnwidth',...
    'width', '0.4\columnwidth' );

x1 = -3:0.1:3;
x2 = -3:0.1:3;
[X1, X2] = meshgrid( x1, x2 );
X = [X1(:) X2(:)];
mu = [0 0];
sigma = [0.25 0.3; 0.3 1];

for k = 0:1e-1:0.5
    S = [k 0; 0 0];
    sigma = sigma + S;
    y = mvnpdf( X, mu, sigma );
    y = reshape( y, length(x2), length(x1) );
    
    surf( x1, x2, y )
    caxis( [0.5*min(y(:))-0.5*max(y(:)), max(y(:))] )
    axis([-3 3 -3 3 0 1])
    
    matlab2animate( 'make', 'frame', 'skip', {'axes'}, opt );
end

close( fig );
matlab2animate( 'make', 'root', opt );
matlab2animate( 'make', 'adjust', 'old', 'font=\color{white!15!black}', 'new', 'fill=none' );
if isunix
    !make
end


function y = mvnpdf( x, mu, sigma )
x = x - mu;
N = size( x, 1 );
y = zeros( N, 1 );
for k = 1:N
    y(k) = x(k,:) * ( sigma \ x(k,:).' );
    y(k) = exp( -0.5*y(k) );
end
