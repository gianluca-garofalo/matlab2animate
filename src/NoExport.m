function output = NoExport( h, cs, output )
%NoExport  Switches off selected object's visibility to not export them.
%   list=NoExport(h,cs), where h is the figure handle and cs is a cell of
%   strings with the names of the object not to export, while list contains
%   all the objects in the figure. If cs is empty or skipped then all
%   objects in output are visible. The third input must never be used. It
%   is only used within the code for the recursion.
%
%   See also: matlab2animate.
%   Implemented by Gianluca Garofalo.


N = nargin;
if N<3
    output = {};
end
if N==1
    cs = {};
end

children = allchild( h );
for n = 1:length(children)
    child = children(n);
    type = get( child, 'Type' );
    
    if ~any( strcmp(type,output) )
        output{end+1} = type;
    end
    
    if any( strcmp(type,cs) )
        set( child, 'Visible', 'off' )
    else
        set( child, 'Visible', 'on' )
    end
    
    output = NoExport( child, cs, output );
end
