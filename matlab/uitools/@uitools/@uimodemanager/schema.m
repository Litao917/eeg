function schema
% uimodemanager class: This class manages interactive modes within
% the context of the MATLAB figure window.

%   Copyright 2005-2013 The MathWorks, Inc.
hPk = findpackage('uitools');
cls = schema.class(hPk,'uimodemanager');

%Properties
p = schema.prop(cls,'CurrentMode','handle');
set(p,'SetFunction',@localSetMode);
set(p,'FactoryValue','');
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';

% A default mode may be specified. Setting this property
% has the side-effect of starting the default mode if no
% mode has already been activated in the figure.
p = schema.prop(cls,'DefaultUIMode','string');
set(p,'SetFunction',@localSetDefault);

p = schema.prop(cls,'Blocking','MATLAB array');
set(p,'FactoryValue',false);

p = schema.prop(cls,'FigureHandle','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'WindowListenerHandles', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'WindowMotionListenerHandles', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'DeleteListener', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'PreviousWindowState', 'MATLAB callback');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls, 'RegisteredModes', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

%------------------------------------------------------------------------%
function newDefault = localSetDefault(hThis, valueProposed)
% Set the default mode for the figure. This will have the side-effect
% of activating the mode if there is no mode currently active.

newDefault = valueProposed;
% If the value is empty, return and take no further action.
if isempty(newDefault)
    return;
end

% Validate that the mode has already been registered with the figure:
actMode = getuimode(hThis.FigureHandle, newDefault);
if isempty(actMode)
    error(message('MATLAB:modes:modemanager:UnregisteredMode'));
end

% If there is already a mode active, return and take no further action.
if ~isempty(hThis.CurrentMode)
    return;
end

% Turn on the default mode.
set(hThis,'CurrentMode',actMode);

%------------------------------------------------------------------------%
function newMode = localSetMode(hThis, valueProposed)
% Register a mode with the mode manager, disabling any active mode and
% enabling the new mode.

if ~isa(valueProposed,'uitools.uimode') && ~isempty(valueProposed)
    error(message('MATLAB:modes:modemanager:InvalidMode'));
end
currMode = get(hThis,'CurrentMode');
if ~isempty(currMode) && ishandle(currMode)
    if ~currMode.Blocking
        %Disable listeners
        graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');
        if currMode.WindowButtonMotionFcnInterrupt
            graphics.internal.setListenerState(hThis.WindowMotionListenerHandles,'off');
        end        
        set(currMode,'Enable','off');
        hThis.Blocking = false;
    else
        error(message('MATLAB:modes:modemanager:CannotInterrupt'));
    end
end

newMode = valueProposed;

if ~isempty(newMode)
    %Register with scribe callbacks to maintain consistency:
    localScribeclearmode(hThis);
    set(newMode,'Enable','on');
    %Enable listeners
    graphics.internal.setListenerState(hThis.WindowListenerHandles,'on');
    if newMode.WindowButtonMotionFcnInterrupt
        graphics.internal.setListenerState(hThis.WindowMotionListenerHandles,'on');
    end
    hThis.Blocking = newMode.Blocking;
end

%----------------------------------------------------------------------%
function localScribeclearmode(hThis)
%Register off function, if necessary
fig = hThis.FigureHandle;
if ~graphicsversion(fig,'handlegraphics')
    if isprop(fig,'ScribeClearModeCallback')
        s = fig.ScribeClearModeCallback;
    else
        s = [];
    end
else
    s = getappdata(fig,'ScribeClearModeCallback');
end
if isempty(s) || ~isequal(s{1},@set)
    scribeclearmode(fig,@set,hThis,'CurrentMode','');
end
    