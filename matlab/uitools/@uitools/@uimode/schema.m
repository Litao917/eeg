function schema
% uimode class: This class is the basis of any interactive modes within
% the context of the MATLAB figure window.

%   Copyright 2005-2010 The MathWorks, Inc.

hPk = findpackage('uitools');
cls = schema.class(hPk,'uimode');

%Public properties which are inherited by other modes:
%Start by defining the mode callbacks
p = schema.prop(cls,'WindowButtonDownFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowButtonDownFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowButtonUpFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowButtonUpFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowButtonMotionFcn','MATLAB callback');
set(p,'SetFunction',{@setMotionFcn});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowKeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowKeyPressFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowKeyReleaseFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowKeyReleaseFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowScrollWheelFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowScrollWheelFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'KeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyPressFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'KeyReleaseFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyReleaseFcn'});
p.AccessFlags.Serialize = 'off';

%Undocumented focus lost callback
p = schema.prop(cls,'WindowFocusLostFcn','MATLAB callback');
set(p,'SetFunction',{@setJavaCallback,'FocusLost'});
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'WindowJavaListeners','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

%Determine whether the mode will take control of the WindowButtonMotionFcn
%callback
p = schema.prop(cls,'WindowButtonMotionFcnInterrupt','MATLAB array'); %logical
set(p,'SetFunction',{@readOnlyWhileRunning,'WindowButtonMotionFcnInterrupt'});
set(p,'FactoryValue',false);

%Determine whether the mode will suspend UICONTROL object callbacks
p = schema.prop(cls,'UIControlInterrupt','MATLAB array'); %logical
set(p,'SetFunction',{@readOnlyWhileRunning,'UIControlInterrupt'});
set(p,'FactoryValue',false);

%Add a listener to take care of the UIControl suspension
p = schema.prop(cls,'UIControlSuspendListener','MATLAB array');
set(p,'Visible','off');
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'UIControlSuspendJavaListener','MATLAB array');
set(p,'Visible','off');
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'KeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyPressFcn'});
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'ModeStartFcn','MATLAB callback');
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'ModeStopFcn','MATLAB callback');
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'ShowContextMenu','MATLAB array'); %logical
set(p,'FactoryValue',true);

p = schema.prop(cls,'Name','MATLAB array');
p.AccessFlags.PublicSet = 'off';

% A mode may be specified to be a one-shot mode. This means that after a
% Button-Up event, the mode will be turned off.
p = schema.prop(cls,'IsOneShot','bool');
p.FactoryValue = false;
set(p,'SetFunction',{@readOnlyWhileRunning,'IsOneShot'});

p = schema.prop(cls,'UseContextMenu','on/off');
set(p,'FactoryValue','on');

p = schema.prop(cls,'FigureHandle','MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

%Callback to determine whether the object's button down function should be
%used
p = schema.prop(cls,'ButtonDownFilter','MATLAB callback');
p.AccessFlags.Serialize = 'off';

%Listeners in support of the ButtonDownFilter:
p = schema.prop(cls,'WindowListenerHandles', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

%Caches for the callback functions used during a filtered callback.
p = schema.prop(cls,'UserButtonUpFcn','MATLAB callback');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'PreviousWindowState', 'MATLAB callback');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

%Pre and post callback functions
p = schema.prop(cls,'ActionPreCallback','MATLAB callback');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'ActionPostCallback','MATLAB callback');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

%Set the default context menu handle
p = schema.prop(cls,'UIContextMenu','MATLAB array');
p.AccessFlags.Serialize = 'off';

%Determine whether the mode can be interrupted by another mode
p = schema.prop(cls,'Blocking','MATLAB array'); %logical
set(p,'FactoryValue',false);
p.Visible = 'off';

%Properties that can be inherited, but will not be visible
p = schema.prop(cls, 'WindowMotionFcnListener', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'FigureState','MATLAB array');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'ModeStateData','MATLAB array');
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Enable','on/off');
p.Visible = 'off';
set(p,'FactoryValue','off');
set(p,'SetFunction',@modeControl);
p.AccessFlags.Serialize = 'off';

% Add a delete listener for the purpose of clearing context menus
p = schema.prop(cls,'DeleteListener','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

% Add a delete listener to the figure.
p = schema.prop(cls,'FigureDeleteListener','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

% Properties to facilitate mode composition:
% A mode may have a parent mode if it is being composed.
p = schema.prop(cls,'ParentMode','handle');
p.Visible = 'off';
set(p,'SetFunction',@localReparentMode);
p.AccessFlags.Serialize = 'off';

% Similar to a mode manager, modes may have modes registered with them.
p = schema.prop(cls,'RegisteredModes','handle vector');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% If a mode is a container mode, it may have a default mode
p = schema.prop(cls,'DefaultUIMode','string');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% A mode can only have one active child mode at a time.
p = schema.prop(cls,'CurrentMode','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Keep a record of listeners on the figure.
p = schema.prop(cls,'ModeListenerHandles','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Keep a binary flag around to keep track of whether we are busy activating
% or not.
p = schema.prop(cls,'BusyActivating','bool');
p.Visible = 'off';
p.AccessFlags.PublicGet = 'off';
p.FactoryValue = false;

%------------------------------------------------------------------------%
function newValue = localReparentMode(hThis,valueProposed)
% Reparent a mode object

% This property may only be set if the mode is not active
if strcmp(hThis.Enable,'on')
    error(message('MATLAB:uimodes:mode:ReadOnlyWhileRunning', propName));
end

% If the property is empty, we may be unparenting from the figure:
if isempty(hThis.ParentMode)
    hManager = uigetmodemanager(hThis.FigureHandle);
    unregisterMode(hManager,hThis);
else
    unregisterMode(hThis.ParentMode,hThis);
end

newValue = valueProposed;

%------------------------------------------------------------------------%
function newValue = readOnlyWhileRunning(hThis,valueProposed,propName)
%Enforce the property being read-only while the mode is active

if strcmp(hThis.Enable,'on')
    error(message('MATLAB:uimodes:mode:ReadOnlyWhileRunning', propName));
else
    newValue = valueProposed;
end

%----------------------------------------------------------------------%
function newValue = setMotionFcn(hThis, valueProposed)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

newValue = valueProposed;
hThis.WindowMotionFcnListener.Callback = @(obj,evd)(localEvaluateMotionCallback(obj,evd,valueProposed));

%----------------------------------------------------------------------%
function newValue = setJavaCallback(hThis, valueProposed, propName)
% Modify the window callback function as specified by the mode. Note: These
% properties are unprotected by a listener and may break if the java
% component's property is modified outside the context of the mode.

if ~usejava('awt')
    newValue = [];
    return;
end
newValue = hThis.setFigureCallback(hThis.FigureHandle,propName, valueProposed);

%----------------------------------------------------------------------%
function localEvaluateMotionCallback(obj,evd,callback)

% Evaluate the callback
hgfeval(callback,obj,evd);