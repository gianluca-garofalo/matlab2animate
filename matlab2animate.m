function opt = matlab2animate( varargin )
%matlab2animate  Description.
%   matlab2animate( 'make', 'root', 'rootname', 'slide.tex', options ).
%
%   See also: matlab2tikz.
%   Implemented by Gianluca Garofalo.

persistent video idx
% Defaults
opt = struct( ...
    'fps',          2                   , ...
    'make',         'frame'             , ...
    'filename',     'video.tex'         , ...
    'rootname',     'slide.tex'         , ...
    'timename',     'timeline.txt'      , ...
    'title',        'My Slide'          , ...
    'height',       0.3                 , ...
    'quality',      100                 , ...
    'bounding_box', [-1.1 -0.8 6 4.6]   , ...    'show_bbox',    true                , ...
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

% The extension of the file has priority
[pathstr, opt.filename, ext] = fileparts( opt.filename );
if ~isempty(ext)
    opt.type = ext(2:end);
end
% TODO: absolute or relative path
% if startsWith( opt.build_dir, '../' )
%     opt.filename = fullfile( pathstr, opt.build_dir, opt.filename );
% else
%     opt.filename = fullfile( opt.build_dir, opt.filename );
% end


switch opt.make
    
    case 'root'
        
        fid = fopen( opt.timename );
        [~, N] = fscanf( fid, '%s' );
        fclose( fid );
        
        name = [opt.build_dir '/' opt.filename];
        
        text = {
            '\documentclass[10pt,aspectratio=169,english]{beamer}'
            '%\usetheme{Warsaw}'
            ''
            '\usepackage{tikz}'
            '\usepackage{animate}'
            ''
            '% the following commands are needed for some matlab2tikz features'
            '\newlength\figH'
            '\newlength\figW'
            '\usepackage{pgfplots}'
            '\pgfplotsset{compat=newest}'
            '\usetikzlibrary{plotmarks}'
            '\usepgfplotslibrary{patchplots}'
            '\usepackage{grffile}'
            ''
            '% the following commands are needed for separate compilation'
            '%\usepackage{subfiles}'
            '%\usepackage{xr}'
            ['%\externaldocument{' opt.rootname '}']
            ''
            ''
            '\begin{document}'
            '\begin{frame}'
            ['	\frametitle{' opt.title '}']
            ''
            '	\centering'
            ['	\setlength{\figH}{' num2str(opt.height) '\columnwidth}']
            ['	\begin{animateinline}[autoplay,loop,timeline=' opt.timename ']{' num2str(opt.fps) '}%']
            ['		\multiframe{' num2str(N) '}{i=0+1}{ \input{' name '\i} }%']
            '	\end{animateinline}%'
            '\end{frame}'
            '\end{document}'
            };
        
        fid = fopen( opt.rootname, 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        
        allframes = sprintf( repmat([name '%d.tex '],1,N), 0:N-1 );
        [~, tmp, ~] = fileparts( opt.rootname );
        text = {
            '.PHONY: all clean slide dvitest'
            'all: slide clean'
            ''
            ['slide: ' opt.rootname ' ' allframes]
            sprintf( ['\tlatexmk -quiet -bibtex -f -pdf -pdflatex="lualatex -interaction=nonstopmode" ' opt.rootname] )
            ''
            'clean:'
            sprintf( ['\tlatexmk -c -bibtex ' opt.rootname] )
            ''
            ['dvitest: ' opt.rootname ' ' allframes]
            sprintf( ['\tlualatex -interaction=nonstopmode --output-format=dvi ' opt.rootname] )
            sprintf( ['\tlualatex -interaction=nonstopmode --output-format=dvi ' opt.rootname] )
            sprintf( ['\tdvisvgm --font-format=woff --exact --bbox=papersize --zoom=-1 -p1,- ' tmp] )
            };
        fid = fopen( 'Makefile', 'w' );
        fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        
        %     case 'slide'
        %
        %         fid = fopen( opt.timename );
        %         [~, N] = fscanf( fid, '%s' );
        %         fclose( fid );
        %
        %         name = fullfile( opt.build_dir, opt.filename );
        %
        %         text = {
        %             '%%\makeatletter'
        %             ['%%\def\input@path{PATH_TO_ROOT/}']
        %             '%%\makeatother'
        %             ['\documentclass[' opt.rootname ']{subfiles}']
        %             ''
        %             '\begin{document}'
        %             '\begin{frame}[t]'
        %             ['	\frametitle{' opt.title '}']
        %             ''
        %             '	\centering'
        %             ['	\setlength{\figH}{' num2str(opt.height) '\columnwidth}']
        %             ['	\begin{animateinline}[autoplay,loop,timeline=' opt.timename ']{' num2str(opt.fps) '}%']
        %             ['		\multiframe{' num2str(N) '}{i=0+1}{ \input{' name '\i} }%']
        %             '	\end{animateinline}%'
        %             '\end{frame}'
        %             '\end{document}'
        %             };
        %
        %         fid = FileOpenForWrite( [opt.filename '.tex'] );
        %         fprintf( fid, '%s', sprintf('%s\n',text{:}) );
        
    case 'background'
        
        mkdir( opt.build_dir );
        
        switch opt.type
            case {'avi', 'mp4'}
                video = VideoWriter( [opt.filename opt.type] );
                video.Quality = opt.quality;
                video.FrameRate = opt.fps;
                open( video );
            case 'png'
                set( gcf, 'Color', 'none' );
            case 'tex'
                set( gcf, 'Color', 'none' );
                idx = 0;
                delete( opt.timename )
                
                CreateTex( idx, opt );
                fid = fopen( opt.timename, 'a' );
                fprintf( fid, '::%dx0\n', idx );
                fclose( fid );
                idx = idx + 1;
                
                %                 if opt.show_bbox
                %                     name = [opt.build_dir '/' opt.filename '_bbox.' opt.type];
                %                     matlab2tikz( name, 'strict', true, 'showInfo', false,...
                %                         'extraCode', {'\show\pgfextractx' '\makeatletter'...
                %                         '\newcommand{\pgfsizesx}{ \pgfpointanchor{current bounding box}{south west} \pgfmathparse{\pgf@x/\pgf@xx} \pgfmathprintnumber{\pgfmathresult} }'...
                %                         '\newcommand{\pgfsizesy}{ \pgfpointanchor{current bounding box}{south west} \pgfmathparse{\pgf@y/\pgf@yy} \pgfmathprintnumber{\pgfmathresult} }'...
                %                         '\newcommand{\pgfsizenx}{ \pgfpointanchor{current bounding box}{north east} \pgfmathparse{\pgf@x/\pgf@xx} \pgfmathprintnumber{\pgfmathresult} }'...
                %                         '\newcommand{\pgfsizeny}{ \pgfpointanchor{current bounding box}{north east} \pgfmathparse{\pgf@y/\pgf@yy} \pgfmathprintnumber{\pgfmathresult} }'...
                %                         '\makeatother'},...
                %                         'extraTikzpictureOptions', {']%' '\pgfsizesx %'...
                %                         '\node { \textcolor{red}{|} }; %' '\pgfsizesy %'...
                %                         '\node { \textcolor{red}{;} }; %' '\pgfsizenx %'...
                %                         '\node { \textcolor{red}{:} }; %' '\pgfsizeny %' '['},...
                %                         'extraAxisOptions', 'enlargelimits=false', 'height', '\figH');
                %                 end
        end
        
    case 'frame'
        
        switch opt.type
            case 'avi'
                writeVideo( video, im2frame(print('-RGBImage')) );
            case 'mp4'
                writeVideo( video, getframe(gcf) );
            case 'png'
                name = sprintf( [opt.filename '%d' opt.type], idx );
                export_fig( name, '-transparent', '-r200', '-q101', '-a1', '-nocrop' );
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
    f = strrep( f, old{k}, new{k} );
end

fid = fopen( file, 'wt' );
fwrite( fid, f );
fclose( fid );


function CreateTex( idx, opt )
coord1 = ['(' num2str(opt.bounding_box(1)) ',' num2str(opt.bounding_box(2)) ')'];
coord2 = ['(' num2str(opt.bounding_box(3)) ',' num2str(opt.bounding_box(4)) ')'];
bbox = ['\useasboundingbox ' coord1 ' rectangle ' coord2 ';%'];

cleanfigure;
NoExport( gcf, opt.skip );
name = sprintf( [opt.build_dir '/' opt.filename '%d.' opt.type], idx );
matlab2tikz( name, 'strict', true, 'showInfo', false,...
    'extraCode', {'\pgfdeclarelayer{foreground}' '\pgfsetlayers{main,foreground}'},...
    'extraTikzpictureOptions', {']%' bbox '['},...
    'extraAxisOptions', 'enlargelimits=false', 'height', '\figH');

ReplaceInFile( name, 'font=\color{white}', 'fill=none' )


%             ''
%             '\title[title]{Awesome Title}'
%             '\author[]{Gianluca~Garofalo}'
%             '\institute[]{German Aerospace Center (DLR)\\Institute of Robotics and Mechatronics}'
%             '\date[]{June 11, 1987}'
%             ''
%             '\begin{frame}[plain,noframenumbering,label=firstframe]'
%             '\titlepage'
%             '\end{frame}'
%             ''
%             '\begin{frame}[t,noframenumbering]'
%             '\thispagestyle{empty}'
%             '\frametitle{Outline}'
%             '\tableofcontents{}'
%             '\end{frame}'
%             ''
