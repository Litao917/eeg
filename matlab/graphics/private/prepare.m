function pj = prepare( pj, h )
%PREPARE Method to modify a Figure or Simulink model for printing.
%   It is not always desirable to have output on paper equal that on screen.
%   The dark backgrounds used on screen would saturate paper with toner. Lines
%   and text colored in light shades would be very hard to see if dithered on 
%   standard gray scale printers. Arguments to PRINT and the state of some 
%   Figure properties dictate what changes are required while rendering the 
%   Figure or model for output.
%
%   Ex:
%      pj = PREPARE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, RESTORE, PREPAREHG, PREPAREUI.

%   Copyright 1984-2011 The MathWorks, Inc.

error(nargchk(2,2,nargin, 'struct') )

if ~pj.UseOriginalHGPrinting
    error(message('MATLAB:print:ObsoleteFunction', upper( mfilename )));
end

if ~isequal(size(h), [1 1]) || ~ishandle( h )
    error(message('MATLAB:print:PrepareNeedsHandle'))
end

%Need to see everything when printing
hiddenH = get( 0, 'showhiddenhandles' );
set( 0, 'showhiddenhandles', 'on' )

try
    err = 0;
    
    pj.PaperUnits = getget( h, 'paperunits' );
    if ~strcmp(pj.Driver, 'mfile')
        %don't set paperunits to points if we're not creating a 
        %file that goes to a printer
       setset( h, 'paperunits', 'points' )
    end
    
    if isfigure( h ) 
        % Create Handle Graphics objects on screen if not already there.
        drawnow
        
        %Make extensive property changes.
        pj = preparehg( pj, h );
    end
    
    %Adobe Illustrator format doesn't allow us to set landscape, draw as portrait
    if strcmp(pj.Driver, 'ill') && ~strcmp('portrait', getget(h,'paperorientation') )
        warning(message('MATLAB:print:IllustratorMustBePortrait'))
        pj.Orientation = getget(h,'paperorientation');
        setset( h, 'paperorientation', 'portrait')
    end
    
    
    %If saving a picture, not a printer format, crop the image by moving its
    %lower-left corner to the lower-left of the page. We will use an option
    %with GS to crop it at the width and height of the PaperPosition.
    %This includes the PS generated when we want to use GS to make a TIFF preview.
    if ( strcmp(pj.DriverClass, 'GS') && pj.DriverExport ) ...
            || (pj.DriverExport  && pj.PostScriptPreview == pj.TiffPreview)
        pj.GhostImage = 1;
    end
    
catch ex
    err = 1;
end

%Pay no attention to the objects behind the curtain
set( 0, 'showhiddenhandles', hiddenH )

if err
    rethrow( ex )
end

% LocalWords:  pj PREPAREHG PREPAREUI paperunits mfile paperorientation
