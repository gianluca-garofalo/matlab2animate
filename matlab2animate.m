function opt = matlab2animate( varargin )
%matlab2animate  Description.
%   matlab2animate( 'make', 'root', 'rootname', 'slide.tex', options ).
%
%   See also: matlab2tikz.
%   Implemented by Gianluca Garofalo.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: fix \useasboundingbox assumption in show_bbox %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

persistent video idx
% Defaults
opt = struct( ...
    'fps',          2                   , ...
    'make',         'frame'             , ...
    'framename',    'video.tex'         , ...
    'rootname',     'slide.tex'         , ...
    'timename',     'timeline.txt'      , ...
    'title',        'My Slide'          , ...
    'height',       '0.3\columnwidth'   , ...
    'width',        -1                  , ...
    'quality',      100                 , ...
    'bounding_box', []                  , ...
    'type',         'tex'               , ...
    'skip',         {''}                , ...
    'old',          ''                  , ...
    'new',          ''                  , ...
    'build_dir',    'build'               ...
    );

% Read the acceptable names
optionNames = fieldnames( opt );

% Update structure with input values
nArgs = length( varargin );
if nArgs
    has_struct = isstruct( varargin{end} );
    if mod(nArgs,2) && ~has_struct
        error( 'matlab2animate: check propertyName/propertyValue pairs')
    end
    
    if has_struct
        inpName = fieldnames( varargin{end} );
        if ~isempty(inpName)
            for k = 1:length(inpName)
                field = inpName{k};
                opt.(field) = varargin{end}.(field);
            end
        end
        input = varargin(1:end-1);
    else
        input = varargin;
    end
    
    for pair = reshape(input,2,[]) % pair is {propName;propValue}
        inpName = lower( pair{1} ); % make case insensitive
        
        if any( strcmp(inpName,optionNames) )
            % overwrite options
            opt.(inpName) = pair{2};
        else
            error( '%s is not a recognized parameter name', inpName )
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: absolute or relative path %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The extension of the file has priority
[~, opt.framename, ext] = fileparts( opt.framename );
if ~isempty(ext)
    opt.type = ext(2:end);
end
[~, opt.rootname, ~] = fileparts( opt.rootname );


switch opt.make
    
    case 'root'
        
        fid = fopen( opt.timename );
        [~, N] = fscanf( fid, '%s' );
        fclose( fid );
        
        bsFname = [opt.build_dir '/' opt.framename];
        bsPDFname = [opt.build_dir '/' opt.rootname '_pdf-figure'];
        PDFname = [opt.rootname '_pdf.tex'];
        SVGname = [opt.rootname '_svg.tex'];
        
        % _pdf.tex
        sizes = {''};
        if opt.height~=-1
            sizes{end+1,1} = ['	\setlength{\figH}{' num2str(opt.height) '}'];
        end
        if opt.width~=-1
            sizes{end+1,1} = ['	\setlength{\figW}{' num2str(opt.width) '}'];
        end
        text = {
            '\documentclass[10pt,aspectratio=169,english]{beamer}',...
            '',...
            '\usepackage{tikz}',...
            '\usepackage{animate}',...
            '',...
            '% For matlab2tikz features',...
            '\newlength\figH',...
            '\newlength\figW',...
            '\usepackage{pgfplots}',...
            '\pgfplotsset{compat=newest}',...
            '\usetikzlibrary{plotmarks}',...
            '\usepgfplotslibrary{patchplots}',...
            '\usepackage{grffile}',...
            '',...
            '% For pdf frames generation',...
            '\usetikzlibrary{external}',...
            '\tikzexternalize',...
            '',...
            '',...
            '\begin{document}',...
            '\begin{frame}',...
            ['	\frametitle{' opt.title '}'],...
            '',...
            '	\centering',...
            sizes{:},...
            ['	\begin{animateinline}[autoplay,loop,timeline=' opt.timename ']{' num2str(opt.fps) '}%'],...
            ['		\multiframe{' num2str(N) '}{i=0+1}{ \input{' bsFname '\i} }%'],...
            '	\end{animateinline}%',...
            '\end{frame}',...
            '\end{document}',...
            };
        
        fid = fopen( PDFname, 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        fclose( fid );
        
        
        % _svg.tex
        text = {
            '\documentclass[dvisvgm,hypertex,10pt,aspectratio=169,english]{beamer}'
            ''
            '\usepackage{animate}'
            ''
            ''
            '\begin{document}'
            '\begin{frame}'
            ['	\frametitle{' opt.title '}']
            ''
            '	\centering'
            ['	\animategraphics[autoplay,loop,timeline=' opt.timename ']{' num2str(opt.fps) '}{' bsPDFname '}{0}{' num2str(N-1) '}']
            '\end{frame}'
            '\end{document}'
            };
        
        fid = fopen( SVGname, 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        fclose( fid );
        
        
        % .html
        text = {
            '<!DOCTYPE html >'
            '<html lang="en-US">'
            '<head>'
            '<meta charset="UTF-8">'
            '<meta name="keywords" content="YOUR, KEYWORDS">'
            '<meta name="description" content="BLABLA">'
            '<meta name="author" content="Gianluca Garofalo">'
            '<title>Perfect Slides</title>'
            '<link rel="stylesheet" type="text/css" media="screen, projection, print" href="Slidy2/styles/slidy.css" />'
            '<script src="Slidy2/scripts/slidy.js" charset="utf-8" type="text/javascript"></script>'
            '</head>'
            '<body>'
            '<div class="slide">'
            '<object type="image/svg+xml" data="PATHTOSVG.svg">'
            '</object>'
            '</div>'
            '</body>'
            '</html>'
            };
        fid = fopen( 'template.html', 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        fclose( fid );
        
        
        % Makefile
        text = {
            '.PHONY: all clean slide'
            ''
            'all: slide clean'
            ''
            'clean:'
            sprintf( ['\tlatexmk -c -bibtex ' PDFname] )
            sprintf( ['\tlatexmk -c -bibtex ' SVGname] )
            sprintf( '\trm -f *.auxlock *.dpth *.log *.md5 *.nav *.snm' )
            ''
            ['slide: ' strrep(SVGname,'.tex','.dvi')]
            sprintf( ['\tdvisvgm --font-format=woff --exact --bbox=papersize --zoom=-1 -p1,- ' strrep(SVGname,'.tex','')] )
            ''
            [strrep(SVGname,'.tex','.dvi') ': ' SVGname ' ' bsPDFname '*.pdf']
            sprintf( ['\tlatex -interaction=nonstopmode ' SVGname] )
            sprintf( ['\tlatex -interaction=nonstopmode ' SVGname] )
            ''
            [bsPDFname '*.pdf: ' strrep(PDFname,'.tex','.pdf') ' ' bsFname '*.tex']
            ''
            [strrep(PDFname,'.tex','.pdf') ': ' PDFname ' ' bsFname '*.tex ' opt.timename]
            sprintf( ['\tlatexmk -quiet -bibtex -f -pdf -pdflatex="lualatex -interaction=nonstopmode -shell-escape" ' PDFname] )
            sprintf( ['\tmv ' opt.rootname '_pdf-figure*.pdf build/'] )

            };
        fid = fopen( 'Makefile', 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        fclose( fid );
        
    case 'background'
        
        mkdir( opt.build_dir );
        idx = 0;
        switch opt.type
            case {'avi', 'mp4'}
                video = VideoWriter( [opt.framename opt.type] );
                video.Quality = opt.quality;
                video.FrameRate = opt.fps;
                open( video );
            case 'tex'
                CreateTex( idx, opt );
                delete( opt.timename )
                fid = fopen( opt.timename, 'a' );
                fprintf( fid, '::%dx0\n', idx );
                fclose( fid );
        end
        idx = idx + 1;
        
    case 'show_bbox' % FIXME: I believe \pgfsize changes the bbox
        
        if strcmp(opt.type,'tex')
            bsFname = [opt.build_dir '/' opt.framename];
            name = [bsFname '_bbox.tex'];
            copyfile( [bsFname '0.tex'], name );
            
            text = {
                '\show\pgfextractx'
                '\makeatletter'
                '\newcommand{\pgfsizesx}{ \pgfpointanchor{current bounding box}{south west} \pgfmathparse{\pgf@x/\pgf@xx} \pgfmathprintnumber{\pgfmathresult} }'
                '\newcommand{\pgfsizesy}{ \pgfpointanchor{current bounding box}{south west} \pgfmathparse{\pgf@y/\pgf@yy} \pgfmathprintnumber{\pgfmathresult} }'
                '\newcommand{\pgfsizenx}{ \pgfpointanchor{current bounding box}{north east} \pgfmathparse{\pgf@x/\pgf@xx} \pgfmathprintnumber{\pgfmathresult} }'
                '\newcommand{\pgfsizeny}{ \pgfpointanchor{current bounding box}{north east} \pgfmathparse{\pgf@y/\pgf@yy} \pgfmathprintnumber{\pgfmathresult} }'
                '\makeatother'
                };
            ReplaceInFile( name, '% This file was created by matlab2tikz.', sprintf('%s\n',text{:}) );
            
            text = {
                '\pgfsizesx %'
                '\node { \textcolor{red}{|} }; %'
                '\pgfsizesy %'
                '\node { \textcolor{red}{;} }; %'
                '\pgfsizenx %'
                '\node { \textcolor{red}{:} }; %'
                '\pgfsizeny %'
                };
            ReplaceInFile( name, ['\useasboundingbox...[' newline ']'], sprintf('%s\n',text{:}) )
        end
        
    case 'frame'
        
        switch opt.type
            case 'avi'
                writeVideo( video, im2frame(print('-RGBImage')) );
            case 'mp4'
                writeVideo( video, getframe(gcf) );
            case 'png'
                bsFname = sprintf( [opt.framename '%d' opt.type], idx );
                export_fig( bsFname, '-transparent', '-r200', '-q101', '-a1', '-nocrop' );
            case 'tex'
                CreateTex( idx, opt );
                fid = fopen( opt.timename, 'a' );
                fprintf( fid, '::%d\n', idx );
                fclose( fid );
        end
        idx = idx + 1;
        
    case 'adjust'
        
        if strcmp(opt.type,'tex') && ~isempty(opt.old)% && length(opt.old)==length(opt.new)
            files = struct2cell( dir([opt.build_dir '/*.tex']) );
            for file = files(1,:)
                ReplaceInFile( [opt.build_dir '/' file{1}], opt.old, opt.new )
            end
        end
        
end



function ReplaceInFile( file, old, new )
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


function CreateTex( idx, opt )
if ~isempty(opt.bounding_box)
    coord1 = ['(' num2str(opt.bounding_box(1)) ',' num2str(opt.bounding_box(2)) ')'];
    coord2 = ['(' num2str(opt.bounding_box(3)) ',' num2str(opt.bounding_box(4)) ')'];
    bbox = ['\useasboundingbox ' coord1 ' rectangle ' coord2 ';%'];
else
    bbox = '%';
end

sizes = {''};
if opt.height~=-1
    sizes{end+1,1} = '''height'', ''\figH''';
end
if opt.width~=-1
    sizes{end+1,1} = '''width'', ''\figW''';
end
tmp = sprintf( '%s,', sizes{:} );

cleanfigure;
NoExport( gcf, opt.skip );
bsFname = sprintf( [opt.build_dir '/' opt.framename '%d.' opt.type], idx );
eval( ['matlab2tikz(''' bsFname '''' tmp ' ''strict'',true,''showInfo'',false,'...
    ' ''extraCode'',{''\pgfdeclarelayer{foreground}'' ''\pgfsetlayers{main,foreground}''},'...
    ' ''extraTikzpictureOptions'',{'']%'' ''' bbox ''' ''[''},'...
    ' ''extraAxisOptions'',''enlargelimits=false'');'] )


function output = NoExport( h, cs, output )
%NoExport  Switches off selected object's visibility to not export them.
%   list=NoExport(h,cs), where h is the figure handle and cs is a cell of
%   strings with the names of the object not to export, while list contains
%   all the objects in the figure. If cs is empty or skipped then all
%   objects in output are visible. The third input must never be used. It
%   is only used within the code for the recursion.
%
%   See also: .
%   Implemented by Gianluca Garofalo.

%#codegen

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
    
    NoExport( child, cs, output );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: If not using Slidy %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%             ''
%             '% expandable flt-point calculation with L3'
%             '\ExplSyntaxOn'
%             '\let\fpEval\fp_eval:n'
%             '\ExplSyntaxOff'
%             ''
%             '% PageDown, PageUp key event handling'
%             '\usepackage[totpages]{zref}'
%             '\usepackage{atbegshi}'
%             '\setbeamertemplate{navigation symbols}{}'
%             '\AtBeginShipout{%'
%             '	\AtBeginShipoutAddToBox{%'
%             '		\special{dvisvgm:raw'
%             '		<defs>'
%             '		<script type="text/javascript">'
%             '		<![CDATA['
%             '			document.addEventListener(''keydown'', function(e){'
%             '				if(e.key==''PageDown''){'
%             '					\ifnum\thepage<\ztotpages'
%             '						document.location.replace(''\jobname-\the\numexpr\thepage+1\relax.svg'');%'
%             '					\fi'
%             '				}else if(e.key==''PageUp''){'
%             '					\ifnum\thepage>1'
%             '						document.location.replace(''\jobname-\the\numexpr\thepage-1\relax.svg'');%'
%             '					\fi%'
%             '				}'
%             '			});'
%             '		]]>'
%             '		</script>'
%             '		</defs>'
%             '		}%'
%             '	}%'
%             '}%'
