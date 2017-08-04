function hThis = createuimode(hThis,hFig,name)
% This function is undocumented and will change in a future release

% Constructor for the uimode

%   Copyright 2013 The MathWorks, Inc.

if ~ishghandle(hFig,'figure')
    error(message('MATLAB:uimode:uimode:InvalidConstructor'));
end
if ~ischar(name)
    error(message('MATLAB:uimode:uimde:InvalidConstructor'));
end

% Begin defining properties of the mode
hThis.FigureHandle = hFig;
hFig = handle(hFig);
hThis.FigureDeleteListener = graphics.internal.createlistener(hFig,'ObjectBeingDestroyed',@(obj,evd)(localDelete(hThis)));
hThis.Name = name;
hThis.WindowMotionFcnListener = graphics.internal.createlistener(hFig,'WindowMouseMotion',@localNoop);

graphics.internal.setListenerState(hThis.WindowMotionFcnListener,'off');
% Set up the listener that takes care of suspending UIControl and UITable objects.
hThis.UIControlSuspendListener = graphics.internal.createlistener(hFig,'WindowMouseMotion',@localNoop);

graphics.internal.setListenerState(hThis.UIControlSuspendListener,'off');
hThis.UIControlSuspendListener.Callback = @(obj,evd)(localUIEvent(obj,evd,hThis));

if usejava('awt')
    % Suspend the JavaFrame warning:
    [ lastWarnMsg, lastWarnId ] = lastwarn; 
    oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    hFrame = handle(get(hFig,'JavaFrame'));
    
    % Restore the warning state:
    warning(oldstate);
    lastwarn(lastWarnMsg,lastWarnId);
    
    hAxisComponent = handle(hFrame.getAxisComponent);
    hThis.UIControlSuspendJavaListener = handle.listener(hAxisComponent,'FocusLost',@localNoop);
    hThis.UIControlSuspendJavaListener.Enable = 'off';
    hThis.UIControlSuspendJavaListener.Callback = @(obj,evd)(localUIEvent(obj,evd,hThis));
end

% Set up a delete listener that cleans up UIContextMenus after the mode
% object is delete
hThis.DeleteListener = event.listener(hThis,'ObjectBeingDestroyed',@localCleanUp);

% Set up listeners to deal with the ButtonDownFilter mechanism:
% Define listeners for window state
window_prop = [findprop(hFig,'WindowButtonDownFcn'),...
    findprop(hFig,'WindowButtonUpFcn'),...
    findprop(hFig,'WindowScrollWheelFcn'),...
    findprop(hFig,'WindowKeyPressFcn'),...
    findprop(hFig,'WindowKeyReleaseFcn'),...
    findprop(hFig,'KeyPressFcn'),...
    findprop(hFig,'KeyReleaseFcn')];

l = graphics.internal.createlistener(hFig,window_prop,'PreSet',@(obj,evd)(localPrepareCallback(obj,evd,hThis)));
l(end+1) = graphics.internal.createlistener(hFig,window_prop,'PostSet',@(obj,evd)(localRestoreCallback(obj,evd,l(end),hThis)));

graphics.internal.setListenerState(l,'off');
hThis.WindowListenerHandles = l;

%-------------------------------------------------------------------------%
function localPrepareCallback(hProp,evd,hThis)
hThis.PreviousWindowState = get(evd.AffectedObject,hProp.Name);
% Assign the mode UserButtonUpFcn to the pending figure WindowButtonUpFcn
% for UDD graphics.
if strcmpi(hProp.Name,'WindowButtonUpFcn') && ishandle(hProp)
     hThis.UserButtonUpFcn = evd.NewValue;
end

%-------------------------------------------------------------------------%
function localRestoreCallback(hProp,evd,listener,hThis)
% Assign the mode UserButtonUpFcn to the pending figure WindowButtonUpFcn
% for MCOS graphics.
if strcmpi(hProp.Name,'WindowButtonUpFcn') && isvalid(hProp)
    hThis.UserButtonUpFcn = hThis.FigureHandle.WindowButtonUpFcn;
end
graphics.internal.setListenerState(listener,'off');
set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);

graphics.internal.setListenerState(listener,'on');

%-------------------------------------------------------------------------%
function localCleanUp(hMode,~) 
% Delete context-menus associated with a mode when the mode is deleted, as
% well as any sub-modes

if ~isempty(hMode.UIContextMenu) && ishghandle(hMode.UIContextMenu)
    delete(hMode.UIContextMenu);
end
% Delete any submodes as well
for childMode = hMode.RegisteredModes
    if isobject(childMode) && isvalid(childMode)
        delete(childMode)
    end
end

%-------------------------------------------------------------------------%
function localUIEvent(~,evd,hMode) 
% Suspends a UIControl or UITable object while the mouse is over it. The 
% control will be unsuspended when the mouse is no longer on top or the 
% figure loses focus.

% If the "FigureState" property of the mode is empty, return early as it
% means we are not ready for the event yet.
figureState = hMode.FigureState;
if isempty(figureState) || ~isstruct(figureState)
    return;
end

if ~graphicsversion(hMode.FigureHandle,'handlegraphics') && isprop(evd,'HitPrimitive')
    currObj = plotedit({'hittestHGUsingMATLABClasses',hMode.FigureHandle,evd});
elseif isprop(evd,'CurrentObject')
    currObj = evd.CurrentObject;
else
    currObj = [];
end

if isequal(currObj,handle(figureState.LastObject))
    return;
end

if ~isempty(figureState.LastObject) && ...
        ishghandle(figureState.LastObject) && ...
        (ishghandle(figureState.LastObject,'uicontrol') || ishghandle(figureState.LastObject,'uitable'))
    set(figureState.LastObject,'Enable',figureState.UIEnableState);
end

if ~graphicsversion(hMode.FigureHandle,'handlegraphics') && isprop(evd,'HitPrimitive')
    % plotedit is used as a gateway function here to its private functions
    currObj = plotedit({'hittestHGUsingMATLABClasses',hMode.FigureHandle,evd});
elseif isprop(evd,'CurrentObject')
    currObj = evd.CurrentObject;
else
    currObj = [];
end
if ~isempty(currObj) && (ishghandle(currObj,'uicontrol') || ishghandle(currObj,'uitable'))
    enableState = get(currObj,'Enable');
    figureState.UIEnableState = enableState;
    if strcmpi(enableState,'on')
        set(currObj,'Enable','Inactive');
    end
end

figureState.LastObject = currObj;
if ~isempty(hMode.FigureState) && isstruct(hMode.FigureState)
    hMode.FigureState = figureState;
end

%-------------------------------------------------------------------------%
function localNoop(varargin)
% This space intentionally left blank

%-------------------------------------------------------------------------%
function localDelete(hThis)
if isobject(hThis) && isvalid(hThis)
    delete(hThis);
end
