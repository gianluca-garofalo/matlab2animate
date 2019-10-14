function opt = matlab2animate( varargin )
%matlab2animate  By calling matlab2animate within the loop used to generate
%each frame of the animation, matlab2animate relies on matlab2tikz to
%export the frame as a tex file. At the end of the loop, slide_pdf.tex is
%created and it uses the latex package animate to create the animation out
%of the tex frames. slide_pdf.tex will also generate a pdf file for each of
%the tex frames. These pdf frames are used by slide_svg.tex to generate an
%animated svg (using once again the animated package). If slide_svg.tex
%contains multiple slides, one svg file per page is generate. Finally, an
%html file can be automatically created with matlab2animate to include all
%the generated svg slides in one html presentation. The latter is based on
%Slidy.
%   options=matlab2animate() returns the default options structure.
%
%   See also: matlab2tikz.
%   Implemented by Gianluca Garofalo.

persistent idx
% Defaults
opt = struct( ...
    'fps',          2                   , ...
    'make',         'frame'             , ...
    'framename',    'video.tex'         , ...
    'slidename',    'slide.tex'         , ...
    'timename',     'timeline.txt'      , ...
    'height',       '0.3\columnwidth'   , ...
    'width',        -1                  , ...
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
    elseif has_struct
        inpName = fieldnames( varargin{end} );
        if ~isempty(inpName)
            for k = 1:length(inpName)
                field = lower( inpName{k} );
                if any( strcmp(field,optionNames) )
                    opt.(field) = varargin{end}.(field);
                else
                    error( 'matlab2animate: %s is not a recognized parameter name', field )
                end
            end
        end
        input = varargin(1:end-1);
    else
        input = varargin;
    end
    
    for pair = reshape(input,2,[]) % pair is {propName;propValue}
        field = lower( pair{1} ); % make case insensitive
        if any( strcmp(field,optionNames) )
            % overwrite options
            opt.(field) = pair{2};
        else
            error( 'matlab2animate: %s is not a recognized parameter name', field )
        end
    end
end

[~, opt.framename, ~] = fileparts( opt.framename );
[~, opt.slidename, ~] = fileparts( opt.slidename );


switch opt.make
    
    case 'slide'
        
        fid = fopen( opt.timename );
        [~, N] = fscanf( fid, '%s' );
        fclose( fid );
        
        bsFname = [opt.build_dir '/' opt.framename];
        bsPDFname = [opt.build_dir '/' opt.slidename '_pdf-figure'];
        PDFname = [opt.slidename '_pdf.tex'];
        SVGname = [opt.slidename '_svg.tex'];
        
        % _pdf.tex
        sizes = {''};
        if opt.height~=-1
            sizes{end+1} = ['	\setlength{\figH}{' opt.height '}'];
        end
        if opt.width~=-1
            sizes{end+1} = ['	\setlength{\figW}{' opt.width '}'];
        end
        filetext = {
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
        fprintf( fid, '%s', sprintf('%s\n',filetext{:}) );
        fclose( fid );
        
        
        % _svg.tex
        filetext = {
            '\documentclass[dvisvgm,hypertex,10pt,aspectratio=169,english]{beamer}'
            ''
            '\usepackage{animate}'
            ''
            ''
            '\begin{document}'
            '\begin{frame}'
            ''
            '	\centering'
            ['	\animategraphics[autoplay,loop,timeline=' opt.timename ']{' num2str(opt.fps) '}{' bsPDFname '}{0}{' num2str(N-1) '}']
            '\end{frame}'
            '\end{document}'
            };
        
        fid = fopen( SVGname, 'w' );
        fprintf( fid, '%s', sprintf('%s\n',filetext{:}) );
        fclose( fid );
        
        
        % Makefile
        filetext = {
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
            sprintf( ['\tmv ' opt.slidename '_pdf-figure*.pdf build/'] )
            };
        
        fid = fopen( 'Makefile', 'w' );
        fprintf( fid, '%s', sprintf('%s\n',filetext{:}) );
        fclose( fid );
        
        
    case 'html'
        
        bsSVGname = [opt.slidename '_svg'];
        files = dir( [bsSVGname '*.svg'] );
        N = length( files );
        if N>1
            ind = zeros( N, 1 );
            for k = 1:N
                [~, name, ~] = fileparts( files(k).name );
                name = strrep( name, [bsSVGname '-'], '' );
                ind(k) = str2double( name );
            end
            ind = sort( ind );
            for k = 1:N
                files(k).name = [bsSVGname '-' num2str(ind(k)) '.svg'];
            end
        end
        
        filetext = cell( N, 1 );
        for k = 1:N
            tmp = {
                '<div class="slide">'
                ['<object type="image/svg+xml" data="' files(k).name '">']
                '</object>'
                '</div>'
                };
            filetext{k} = sprintf( '%s\n', tmp{:} );
        end
        
        filetext = {
            '<!DOCTYPE html >',...
            '<html lang="en-US">',...
            '<head>',...
            '<meta charset="UTF-8">',...
            '<meta name="keywords" content="YOUR, KEYWORDS">',...
            '<meta name="description" content="YOUR, DESCRIPTION">',...
            '<meta name="author" content="Gianluca Garofalo">',...
            '<title>YOUR TITLE</title>',...
            '<link rel="stylesheet" type="text/css" media="screen, projection, print" href="Slidy/styles/slidy.css" />',...
            '<script src="Slidy/scripts/slidy.js" charset="utf-8" type="text/javascript"></script>',...
            '</head>',...
            '<body>',...
            filetext{:},...
            '</body>',...
            '</html>',...
            };
        
        fid = fopen( [opt.slidename '.html'], 'w' );
        fprintf( fid, '%s', sprintf('%s\n',filetext{:}) );
        fclose( fid );
        
    case 'background'
        
        mkdir( opt.build_dir );
        delete( opt.timename );
        
        idx = 0;
        if ~all( strcmp(opt.skip,NoExport(gcf)) )
            CreateTex( idx, opt );            
            fid = fopen( opt.timename, 'a' );
            fprintf( fid, '::%dx0\n', idx );
            fclose( fid );
            idx = idx + 1;
        end
        
    case 'frame'
        
        CreateTex( idx, opt );
        fid = fopen( opt.timename, 'a' );
        fprintf( fid, '::%d\n', idx );
        fclose( fid );
        idx = idx + 1;
        
    case 'adjust'
        
        if ~isempty(opt.old) && length(opt.old)==length(opt.new)
            files = struct2cell( dir([opt.build_dir '/*.tex']) );
            for file = files(1,:)
                ReplaceInFile( [opt.build_dir '/' file{1}], opt.old, opt.new )
            end
        end
        
    otherwise
        error( 'matlab2animate: I do not know how to make %s', opt.make )
        
end



function CreateTex( idx, opt )
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
bsFname = sprintf( [opt.build_dir '/' opt.framename '%d.tex'], idx );
eval( ['matlab2tikz(''' bsFname '''' tmp ' ''strict'',true,''showInfo'',false,'...
    ' ''extraCode'',{''\pgfdeclarelayer{foreground}'' ''\pgfsetlayers{main,foreground}''},'...
    ' ''extraAxisOptions'',''enlargelimits=false'');'] )




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO:                              %
%       1) absolute or relative path %
%       2) If not using Slidy        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
