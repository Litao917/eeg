function [hThis] = uimodemanager(hFig)
% Constructor for the mode

%   Copyright 2005-2011 The MathWorks, Inc.

% Syntax: uitools.uimodemanager(figure)
if ~ishghandle(hFig,'figure')
    error(message('MATLAB:uimodes:modemanager:InvalidConstructor'));
end

% There can only be one mode manager per figure
if ~isprop(hFig,'ModeManager')
    if graphicsversion(hFig,'handlegraphics')
        %Add an instance property to the figure which cannot be copied
        p = schema.prop(hFig,'ModeManager','handle');
        p.AccessFlags.Copy = 'off';
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    else
        p = addprop(hFig,'ModeManager');
        p.Hidden = true;
        p.Transient = true;
    end
end
if isempty(get(hFig,'ModeManager')) || ~ishandle(get(hFig,'ModeManager'))
    % Constructor
    hThis = uitools.uimodemanager;
    hThis.FigureHandle = hFig;
    hFig = handle(hFig);
    
    hThis.DeleteListener = graphics.internal.createlistener(hFig,'ObjectBeingDestroyed',@(obj,evd)(localDelete(hThis)));
    if graphicsversion(hFig,'handlegraphics')
        s = getappdata(hFig,'ScribeClearModeCallback');
    else
        if isprop(hFig,'ScribeClearModeCallback')
            s = hFig.ScribeClearModeCallback;
        else
            s = [];
        end
    end
    %To prevent odd behavior when copying, make sure the scribe callback
    %doesn't refer to a different figure:
    if ~isempty(s) && isequal(s{1},@set)
        if isa(handle(s{2}),'uitools.uimodemanager') && ~isequal(s{2}.FigureHandle, hFig)
            if ~graphicsversion(hFig,'handlegraphics')
                if isprop(hFig,'ScribeClearModeCallback')
                    hFig.ScribeClearModeCallback = [];
                end
            else
                rmappdata(hFig,'ScribeClearModeCallback');
            end
        end
    end
    % Define listeners for window state
    window_prop = [findprop(hFig,'WindowButtonDownFcn'),...
        findprop(hFig,'WindowButtonUpFcn'),...
        findprop(hFig,'WindowScrollWheelFcn'),...
        findprop(hFig,'WindowKeyPressFcn'),...
        findprop(hFig,'WindowKeyReleaseFcn'),...
        findprop(hFig,'KeyPressFcn'),...
        findprop(hFig,'KeyReleaseFcn')];
    
    l = graphics.internal.createlistener(hFig,window_prop,'PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
    l(end+1) = graphics.internal.createlistener(hFig,window_prop,'PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));

    graphics.internal.setListenerState(l,'off');
    hThis.WindowListenerHandles = l;
    
    l = graphics.internal.createlistener(hFig,findprop(hFig,'WindowButtonMotionFcn'),'PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
    l(end+1) = graphics.internal.createlistener(hFig,findprop(hFig,'WindowButtonMotionFcn'),'PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));
    
    graphics.internal.setListenerState(l,'off');
    hThis.WindowMotionListenerHandles = l;
    
    set(hFig,'ModeManager',hThis);
else
    error(message('MATLAB:uimodes:modemanager:ExistingManager'));
end

%------------------------------------------------------------------------%
function localModeWarn(hProp,evd,hThis)
hThis.PreviousWindowState = get(evd.AffectedObject,hProp.Name);
warning(message('MATLAB:modes:mode:InvalidPropertySet', hProp.Name));

%------------------------------------------------------------------------%
function localModeRestore(hProp,evd,listener,hThis)
graphics.internal.setListenerState(listener,'off');
set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);
graphics.internal.setListenerState(listener,'on');

%------------------------------------------------------------------------%
function localDelete(hThis)
if ishandle(hThis)
    delete(hThis);
end
