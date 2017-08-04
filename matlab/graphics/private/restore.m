function pj = restore( pj, h )
%RESTORE Reset a Figure or Simulink model after printing.
%   When printing a model or Figure, some properties have to be changed
%   to create the desired output. RESTORE resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = RESTORE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PREPARE, RESTOREHG, RESTOREUI.

%   Copyright 1984-2011 The MathWorks, Inc. 

error( nargchk(2,2,nargin) )
 
if ~pj.UseOriginalHGPrinting
    error(message('MATLAB:print:ObsoleteFunction', upper( mfilename )));
end

if ~isequal(size(h), [1 1]) | ~ishandle( h )
    error(message('MATLAB:print:InvalidHandleFigureOrModel'))
end

%Need to see everything when printing
hiddenH = get( 0, 'showhiddenhandles' );
set( 0, 'showhiddenhandles', 'on' )

try
    err = 0;
    
    if isfigure(h)
        pj = restorehg( pj, h );
    end
        
    setset( h, 'paperunits', pj.PaperUnits );
    pj.PaperUnits = ''; %not needed anymore
    
    %May have changed orientation because of device
    if ~isempty( pj.Orientation )
        setset(h,'paperorientation', pj.Orientation)
        pj.Orientation = '';
    end
    

catch ex
    err = 1;
end

%Pay no attention to the objects behind the curtain
set( 0, 'showhiddenhandles', hiddenH )

if err
    rethrow( ex )
end

% LocalWords:  pj RESTOREHG RESTOREUI paperunits paperorientation
