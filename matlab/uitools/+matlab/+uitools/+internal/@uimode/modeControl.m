function newValue = modeControl(hThis,valueProposed)
% This function is undocumented and will change in a future release

%Prepare and restore the mode state.

%   Copyright 2013 The MathWorks, Inc.

newValue = valueProposed;

hManager = uigetmodemanager(hThis.FigureHandle);
%Disable listeners on the mode manager:
graphics.internal.setListenerState(hManager.WindowListenerHandles,'off');

if strcmp(valueProposed,'on')
    localPrepareFigure(hThis);
    hgfeval(hThis.ModeStartFcn);
    localStartMode(hThis);
else
    localEndMode(hThis);
    %Disable listeners on the mode manager:
    graphics.internal.setListenerState(hManager.WindowListenerHandles,'off');
    hgfeval(hThis.ModeStopFcn);    
    localRecoverFigure(hThis);
end

%--------------------------------------------------------------------%
function localPrepareFigure(hThis)
hFig = hThis.FigureHandle;

if ~graphicsversion(hFig,'handlegraphics')
    set(hFig,'UIModeEnabled','on');
end

appdata.WindowButtonDownFcn = get(hFig,'WindowButtonDownFcn');
appdata.WindowButtonUpFcn = get(hFig,'WindowButtonUpFcn');
appdata.WindowScrollWheelFcn = get(hFig,'WindowScrollWheelFcn');
appdata.WindowKeyPressFcn = get(hFig,'WindowKeyPressFcn');
appdata.WindowKeyReleaseFcn = get(hFig,'WindowKeyReleaseFcn');
appdata.Pointer = get(hFig,'Pointer');
appdata.PointerShapeCData = get(hFig,'PointerShapeCData');
appdata.PointerShapeHotSpot = get(hFig,'PointerShapeHotSpot');
appdata.KeyPressFcn = get(hFig,'KeyPressFcn');
appdata.KeyReleaseFcn = get(hFig,'KeyReleaseFcn');
if hThis.WindowButtonMotionFcnInterrupt
    appdata.WindowButtonMotionFcn = get(hFig,'WindowButtonMotionFcn');
    set(hFig,'WindowButtonMotionFcn','');
end
appdata.doContext = false;
appdata.numButtonsDown = 0;
hThis.FigureState = appdata;

%--------------------------------------------------------------------%
function localRecoverFigure(hThis)
hFig = hThis.FigureHandle;
appdata = hThis.FigureState;

% If appdata is empty, return early.
if isempty(appdata)
    return;
end

graphics.internal.setListenerState(hThis.WindowMotionFcnListener,'off');
graphics.internal.setListenerState(hThis.UIControlSuspendListener,'off');
set(hThis.UIControlSuspendJavaListener,'Enabled','off');

if isempty(hThis.WindowJavaListeners)
    fNames = {};
else
    fNames = fieldnames(hThis.WindowJavaListeners);
end
for i = 1:length(fNames)
    set(hThis.WindowJavaListeners.(fNames{i}),'Enabled','off');
end

hThis.FigureState = [];

%Restore the context menu of the previously clicked object
if appdata.doContext
    if isfield(appdata,'CurrentObj') && ishghandle(appdata.CurrentObj.Handle)
        set(appdata.CurrentObj.Handle,'UIContextMenu',appdata.CurrentObj.UIContextMenu);
    end
    if isfield(appdata,'CurrentContextMenuObj') && ishghandle(appdata.CurrentContextMenuObj.Handle)
        set(appdata.CurrentContextMenuObj.Handle,'UIContextMenu',appdata.CurrentContextMenuObj.UIContextMenu);
    end
end

if isfield(appdata,'LastObject') && ~isempty(appdata.LastObject) && ...
        ishandle(appdata.LastObject) && ...
        (ishghandle(appdata.LastObject,'uicontrol') || ishghandle(appdata.LastObject,'uitable'))
    set(appdata.LastObject,'Enable',appdata.UIEnableState);
end

if ~graphicsversion(hFig,'handlegraphics')
    set(hFig,'UIModeEnabled','off');
end

set(hFig,'WindowButtonDownFcn',appdata.WindowButtonDownFcn);
set(hFig,'WindowButtonUpFcn',appdata.WindowButtonUpFcn);
set(hFig,'WindowScrollWheelFcn',appdata.WindowScrollWheelFcn);
set(hFig,'WindowKeyPressFcn',appdata.WindowKeyPressFcn);
set(hFig,'WindowKeyReleaseFcn',appdata.WindowKeyReleaseFcn);
set(hFig,'Pointer',appdata.Pointer);
set(hFig,'PointerShapeCData',appdata.PointerShapeCData);
set(hFig,'PointerShapeHotSpot',appdata.PointerShapeHotSpot);
set(hFig,'KeyPressFcn',appdata.KeyPressFcn);
set(hFig,'KeyReleaseFcn',appdata.KeyReleaseFcn);
if hThis.WindowButtonMotionFcnInterrupt
    set(hFig,'WindowButtonMotionFcn',appdata.WindowButtonMotionFcn);
end

%--------------------------------------------------------------------%
function localStartMode(hThis)
hFig = hThis.FigureHandle;


set(hFig,'WindowButtonUpFcn',{@localModeWindowButtonUpFcn,hThis,hThis.WindowButtonUpFcn});
set(hFig,'WindowButtonDownFcn',{@localModeWindowButtonDownFcn,hThis,hThis.WindowButtonDownFcn});
graphics.internal.setListenerState(hThis.WindowMotionFcnListener,'on');
set(hFig,'WindowKeyPressFcn',{@localModeWindowKeyPressFcn,hThis,hThis.WindowKeyPressFcn});
set(hFig,'WindowKeyReleaseFcn',{@localModeWindowKeyReleaseFcn,hThis,hThis.WindowKeyReleaseFcn});
set(hFig,'WindowScrollWheelFcn',hThis.WindowScrollWheelFcn);
set(hFig,'KeyPressFcn',{@localModeKeyPressFcn,hThis,hThis.KeyPressFcn});
set(hFig,'KeyReleaseFcn',hThis.KeyReleaseFcn);
if isempty(hThis.WindowJavaListeners)
    fNames = {};
else
    fNames = fieldnames(hThis.WindowJavaListeners);
end
for i = 1:length(fNames)
    set(hThis.WindowJavaListeners.(fNames{i}),'Enabled','on');
end
if hThis.UIControlInterrupt
    graphics.internal.setListenerState(hThis.UIControlSuspendListener,'on');
    set(hThis.UIControlSuspendJavaListener,'Enabled','on');
end

% Initialize the last object
hThis.FigureState.LastObject = [];
% If the mode has a default mode set, activate it now:
if ~isempty(hThis.DefaultUIMode)
    hThis.BusyActivating = true;
    activateuimode(hThis,hThis.DefaultUIMode);
    hThis.BusyActivating = false;
end

%--------------------------------------------------------------------%
function localEndMode(hThis)
% If the mode has a submode active, stop it before continuing

% Suspend the Window Listeners
graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');

activateuimode(hThis,hThis.DefaultUIMode);
activateuimode(hThis,'');

if ~isempty(hThis.ModeListenerHandles)
    graphics.internal.setListenerState(hThis.ModeListenerHandles,'off');
end

%------------------------------------------------------------------------%
function localModeWindowButtonDownFcn(hFig,evd,hThis,newValue)
hThis.modeWindowButtonDownFcn(hFig,evd,hThis,newValue);

%------------------------------------------------------------------------%
function localModeWindowButtonUpFcn(hFig,evd,hThis,newValue)
hThis.modeWindowButtonUpFcn(hFig,evd,hThis,newValue);

%------------------------------------------------------------------------%
function localModeWindowKeyPressFcn(hFig,evd,hThis,newValue)

hThis.modeWindowKeyPressFcn(hFig,evd,hThis,newValue);

%------------------------------------------------------------------------%
function localModeWindowKeyReleaseFcn(hFig,evd,hThis,newValue)

hThis.modeWindowKeyReleaseFcn(hFig,evd,hThis,newValue);

%------------------------------------------------------------------------%
function localModeKeyPressFcn(hFig,evd,hThis,newValue)

hThis.modeKeyPressFcn(hFig,evd,hThis,newValue);
