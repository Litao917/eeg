function pj = preparehg( pj, h )
%PREPAREHG Method to ready a Figure for printing.
%   Modify properties of a Figure and its children based on property values
%   and PrintJob state. Changes include color of objects and size of Figure
%   on screen if a ResizeFcn needs to be called.
%   Creates and returns a structure with fields containing various data
%   we have to save for restoration of the Figure and its children.
%
%   Ex:
%      pj = PREPAREHG( pj, h ); %modifies PrintJob object pj and Figure h
%
%   See also PRINT, PREPARE, RESTORE, RESTOREHG.

%   Copyright 1984-2012 The MathWorks, Inc.

%   Uses structure because of the danger of not clearing out state variables
%   in the PrintJob object between renderings of different Figures.
%   ResizeFcn          %Original value of ResizeFcn, nulled out during print
%   ResizedWindow      %True if had to resize Figure on screen because of ResizeFcn
%   WindowUnits        %Original Window units while we work in points
%   WindowPos          %Original Window position in original units
%   PixelObjects       %Vector of handles to objects positioned in pixel units
%   FontPixelObjects   %Vector of handles to objects with FontUnits of pixels
%   Inverted           %1 = Force white background 2 = force transparent background
%   Undithered         %True if changed foreground colors of Text and Lines to black
%   Renderer           %Save original renderer if using different one while printing
%   RendererAutoMode   %If setting different renderer, don't change mode as a result
%   PrintTemplate      %Copy of Figure's template for output formating with saved state for later restoration

narginchk(2,2) 

if ~pj.UseOriginalHGPrinting
    error(message('MATLAB:print:ObsoleteFunction', upper( mfilename )));
end

if ~isequal(size(h), [1 1]) || ~isfigure( h )
    error(message('MATLAB:preparehg:InvalidHandle'))
end

% Indicate that we are about to start printing.
setappdata(0,'BusyPrinting',true);
fireprintbehavior(h,'PrePrintCallback');

%Early exit, want to save Figure as is.
if strcmp(pj.Driver, 'mfile')
    pj.hgdata = [];
    return
end

%Figures can be formatted for output via a PrintTemplate object
pt = getprinttemplate(h);
if isempty( pt )
    hgdata.PrintTemplate = [];
else
    hgdata.PrintTemplate = ptpreparehg( pt, h );
end

%Fun with resize functions.
%--------------------------
%Make Figure the size it is going to be while printing (i.e. PaperPosition).
%This will cause the user's ResizeFcn to be called while the Figure is
%still at screen resolution. This gives the user a chance to move and
%resize things the way s/he wants. Afterwards the ResizeFcn is nulled,
%always, so that the resizing of the Figure that happens internally
%when changing to the driver resolution does not cause any
%weird results. For the same reason, objects in Pixel units are
%set to Points so they do not draw screenDPI/driverDPI too small or big.

adjustResizeFcn = 1;
rf = get( h, 'ResizeFcn' );
if ischar(rf)
    if strcmp( rf, 'legend(''ResizeLegend'')' ) ...
            || strcmp( rf, 'doresize(gcbf)')
        
        %This is a known good ResizeFcn, can handle being called during
        %printing, so let's not resize on screen and output the warning.
        hgdata.ResizeFcn = '';
        hgdata.ResizedWindow = 0;
        adjustResizeFcn = 0;
    end
end
if adjustResizeFcn
    hgdata.ResizeFcn = rf;
    if isempty(hgdata.ResizeFcn) || strcmp( 'auto', get( h, 'paperpositionmode' ) )
        hgdata.ResizedWindow = 0;
    else
        hgdata.ResizedWindow = 1;
        hgdata.WindowUnits = get( h, 'units' );
        hgdata.WindowPos = get( h, 'position' );
        set( h, 'units', 'points' )
        pointsWindowPos = get( h, 'position' );
        pointsPaperPos = getget( h, 'paperposition' ); %already in points units
        set( h, 'units', hgdata.WindowUnits )
        
        if (pointsWindowPos(3)~=pointsPaperPos(3)) || ...
                (pointsWindowPos(4)~=pointsPaperPos(4))
            printbehavior = hggetbehavior(h,'Print','-peek');
            if isempty(printbehavior) || ...
                    strcmp(printbehavior.WarnOnCustomResizeFcn,'on')
                warning(message('MATLAB:print:CustomResizeFcnInPrint'));
            end
            screenpos( h, [ pointsWindowPos(1:2) pointsPaperPos(3:4) ] );
            %Implicit drawnow in getframe not reliable, may not have any UIControls
            drawnow
        end
    end
    if ~isempty(hgdata.ResizeFcn )
        set( h, 'ResizeFcn', '' );
    end
end

%%%Capture images to stand in place of uicontrols which do not print.
pj = prepareui(pj, h);

%PrintUI stuff may have made, or there already existed, Pixel position Axes.
%Set all Pixel objects to Points so they handle being printed at driver DPI.
hgdata.PixelObjects = [findall(h,'type','axes',       'units','pixels')
    findall(h,'type','text',       'units','pixels')
    findall(h,'type','uipanel',    'units','pixels')
    findall(h,'type','uicontainer','units','pixels')];
if ~isempty( hgdata.PixelObjects )
    set( hgdata.PixelObjects, 'units', 'points' )
end
%Same thing for Axes and Text objects with FontUnits set to pixels.
hgdata.FontPixelObjects = [findall(h,'type','axes',       'fontunits','pixels')
    findall(h,'type','text',       'fontunits','pixels')
    findall(h,'type','uipanel',    'fontunits','pixels')
    findall(h,'type','uicontainer','fontunits','pixels')];
if ~isempty( hgdata.FontPixelObjects )
    set( hgdata.FontPixelObjects, 'fontunits', 'points' )
end


% Possibly invert B&W color properties of Figure and child objects
% The following should be changed when we add "transparent" as a "Inverted" option
% CopyOptions is set in uiw\menu_w.c as a flag to let us know where we came from

hgdata.Inverted = 0;
hasPrefs = 0;
honorPrefs = 0;
if usejava('awt')
    try %#ok
        honorPrefs = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', ...
            'CopyOptions.HonorCOPrefs') ~= 0;
        hasPrefs = 1;
    end
end
if (hasPrefs && honorPrefs)
    figbkcolor = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', 'CopyOptions.FigureBackground');
    if isequal(figbkcolor, 0)  % "none"
        hgdata.Inverted = 2;
        localcolornone('save', h);
    elseif isequal(figbkcolor, 1)
        hgdata.Inverted = 1;
        adjustbackground('save', h);
    end
else
    if strcmp('on', get(h,'InvertHardcopy'))
        hgdata.Inverted = 1;
        adjustbackground('save', h);
    end
end

% Possibly set Lines and Text to B or W, what contrasts with background
if blt(pj,h)
    hgdata.Undithered = 0;
else
    hgdata.Undithered = 1;
    contrastcolors('save', h);
end

%Deselect all objects so that we do not print their selection handles.
noselection('save',h);

% if printing to JPEG or TIFF file, then we need to convert animated
% objects to 'erasemode','normal' so that they will render into the
% Z-Buffer. Same if producing TIFF for EPS preview of printed Figure.
if strcmp(pj.DriverClass, 'IM') || ((pj.PostScriptPreview == pj.TiffPreview) && ~pj.GhostImage)
    [prevWarnMsg, prevWarnID] = lastwarn;
    noanimateWarn = warning('off', 'MATLAB:noanimate:DeprecatedFunction');
    noanimate('save',h);
    warning(noanimateWarn);
    lastwarn(prevWarnMsg, prevWarnID);
end

%If not using Painters renderer (i.e. Figure is not set to Painters or user asked for Z) ...
if strcmp(get(h,'rendererMode'),'manual') && ~(strcmp( 'painters', get(h,'renderer')) || strcmp(pj.Renderer,'painters') )
    %and if using a driver or on an X system that can not create Zbuffer ...
    if (strcmp(pj.Driver, 'hpgl') || strcmp(pj.Driver, 'ill')) || pj.XTerminalMode
        %just use Painters
        if ~strcmp(pj.Renderer,'painters') && ~isempty(pj.Renderer)
            ren = pj.Renderer;
        else
            ren = get(h,'renderer');
        end
        if ~pj.XTerminalMode
            warning(message('MATLAB:print:BadPrintDeviceRenderer', upper( pj.Driver ), ren))
        end
        pj.Renderer = 'painters';
    end
end

% Temporary workaround for opengl printing problem - use zbuffer  - now
% turned off
%if (~isempty( pj.Renderer )  && strcmpi(pj.Renderer, 'opengl')) || ...
%        (isempty( pj.Renderer ) && strcmpi( get(h, 'renderer'), 'opengl'))
%    pj.Renderer = 'zbuffer';
%end

% If renderer is None, set it to painters for the print rendering, then
% set it back.
if strcmp(get(h,'renderer'),'None')
    pj.Renderer = 'painters';
end

% Set render to use while printing now
if ~isempty( pj.Renderer )
    hgdata.Renderer = get( h, 'renderer' );
    hgdata.RendererAutoMode = strcmp( get( h, 'renderermode' ), 'auto' );
    set( h, 'renderer', pj.Renderer )
end

%Save it in object for later retrieval
pj.hgdata = hgdata;

function localcolornone(option, handle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We need to suppress color none warnings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cleaner = doWarnSetup;
colornone(option, handle);
delete(cleaner);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function cleaner = doWarnSetup
[ state.lastWarnMsg, state.lastWarnId ] = lastwarn;
state.usagewarning =warning('off','MATLAB:hg:ColorSpec_None');
cleaner = onCleanup(@()restoreWarningState(state));

function restoreWarningState(oldstate)
warning(oldstate.usagewarning);
lastwarn(oldstate.lastWarnMsg, oldstate.lastWarnId);


% LocalWords:  pj RESTOREHG nulled Undithered formating mfile DPI
% LocalWords:  paperpositionmode paperposition uicontrols fontunits uiw awt
% LocalWords:  erasemode IM Zbuffer hpgl zbuffer renderermode
