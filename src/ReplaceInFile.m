function ReplaceInFile( file, old, new )
%ReplaceInFile  Description.
%   Description.
%
%   See also: matlab2animate.
%   Implemented by Gianluca Garofalo.


fid = fopen( file, 'rt' );
f = fread( fid );
fclose( fid );

f = char( f.' );
if ~iscellstr(old)
    [old, new] = deal( {old}, {new} );
end
for k = 1:length(old)
    pos = strfind( old{k}, '...' );
    if ~isempty(pos)
        ellipses = extractBetween( f, old{k}(1:pos-1), old{k}(pos+3:end) );
        old{k} = [old{k}(1:pos-1) char(ellipses) old{k}(pos+3:end)];
    end
    f = strrep( f, old{k}, new{k} );
end

fid = fopen( file, 'wt' );
fwrite( fid, f );
fclose( fid );
