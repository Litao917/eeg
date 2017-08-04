function deselectall(fig)
%DESELECTALL Deselect all selected objects.

%   DESELECTALL(FIG) deselects all selected objects in the
%   figure FIG.
%
%   See also GETSELECTOBJECTS, SELECTOBJECT.

%   Copyright 1984-2011 The MathWorks, Inc.
%   $  $  $  $


error(nargchk(1,1,nargin,'struct'));

if isempty(fig), return; end

if ~ishghandle(fig,'figure')
    error(message('MATLAB:deselectall:invalidargument'));
end

% Since this may be called from outside the mode, obtain the mode for the
% given figure handle.
hMan = uigetmodemanager(fig);
hCurrMode = hMan.CurrentMode;
hPlotEdit = [];
if ~isempty(hCurrMode)
    hPlotEdit = hCurrMode.getuimode('Standard.EditPlot');
end
if isempty(hPlotEdit)
    hPlotEdit = plotedit(fig,'getmode');
end
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

% Make sure we have valid handles to deal with. Otherwise, explosions may
% occur
localFixSelectedObjs(hMode);

% Deselect the objects:
set(hMode.ModeStateData.SelectedObjects,'Selected','off');

% Update the mode state:
hMode.ModeStateData.SelectedObjects = handle(fig([]));
hMode.ModeStateData.MoveVector = [];
hMode.ModeStateData.CutCopyVector = [];
hMode.ModeStateData.PasteVector = [];
hMode.ModeStateData.DeleteVector = [];
hMode.ModeStateData.CurrentClasses = {};
hMode.ModeStateData.MovePossible = false;
hMode.ModeStateData.CutCopyPossible = false;
hMode.ModeStateData.PastePossible = false;
hMode.ModeStateData.DeletePossible = false;
hMode.ModeStateData.IsHomogeneous = true;

% For reverse compatibility, add this information to the scribe axes:
hScribeAxes = graph2dhelper('findScribeLayer',fig);
if graphicsversion(fig,'handlegraphics')
    hScribeAxes.SelectedObjects = hMode.ModeStateData.SelectedObjects;
end

% Send an event broadcasting the change in object selection:
pm = graph2dhelper('getplotmanager','-peek');
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditBeforePaste');
    set(evdata,'SelectedObjects',hMode.ModeStateData.SelectedObjects,...
        'Figure',fig);
    send(pm,'PlotSelectionChange',evdata);
end

% Since what we can and cannot do has changed, updated the edit menu.
plotedit({'update_edit_menu',fig,false});        

%--------------------------------------------------------------------%
function localFixSelectedObjs(hMode)

% remove invalid handles from slectobjs list
hMode.ModeStateData.SelectedObjects(~ishandle(hMode.ModeStateData.SelectedObjects)) = [];
