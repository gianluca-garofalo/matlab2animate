p = mfilename( 'fullpath' );
[path, name, ext] = fileparts( p );
addpath( fullfile(path,'src') );
addpath( fullfile(path,'matlab2tikz','src') );
