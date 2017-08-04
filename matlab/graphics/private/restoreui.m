function pj = restoreui( pj, Fig )
%RESTOREUI Remove Images used to mimic user interface controls in output.
%   When printing a Figure with Uicontrols, the user interface objects
%   can not be drawn in the output. So Images were created to fill in 
%   for the Uicontrols in the output. We now remove those Images.
%
%   Ex:
%      pj = RESTOREUI( pj, h ); %removes Images from Figure h, modifes pj
%
%   See also PRINT, PRINTOPT, PREPAREUI, RESTORE, RESTOREUI.

%   Copyright 1984-2013 The MathWorks, Inc.

error( nargchk(2,2,nargin) )

if ~pj.UseOriginalHGPrinting
    error(message('MATLAB:print:ObsoleteFunction', upper( mfilename )));
end

if ~isequal(size(Fig), [1 1]) | ~isfigure( Fig )
    error(message('MATLAB:print:InvalidHandleFigure'))
end
    

%UIData is empty if never saved mimiced any controls because 
%user requested we don't print them or becaus ef previously
%found and reported problems.
if isempty( pj.UIData )
    return
end

if ~strcmp(get(Fig, 'Visible'), pj.UIData.OldFigVisible)
    set( Fig, 'Visible', pj.UIData.OldFigVisible );
end

if ~isempty(pj.UIData.UICHandles)
  set(pj.UIData.UICHandles,{'Units'},pj.UIData.UICUnits);
  set(pj.UIData.UICHandles,'visible','on');
end
delete(pj.UIData.AxisHandles(find(ishandle(pj.UIData.AxisHandles))));
set(Fig, 'Colormap', pj.UIData.OldFigCMap );

if pj.UIData.MovedFigure
    set(Fig, 'Position', pj.UIData.OldFigPosition );
end

% restore original CurrentAxes, if any
if ~isempty(pj.UIData.CurrentAxes ) && ishghandle(pj.UIData.CurrentAxes, 'axes')
   set(Fig, 'CurrentAxes', pj.UIData.CurrentAxes); 
end


pj.UIData = [];


% LocalWords:  Uicontrols pj PREPAREUI
