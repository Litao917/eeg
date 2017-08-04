function modeWindowKeyPressFcn(~,hFig,evd,hThis,newKeyPressFcn)
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2013 The MathWorks, Inc.

%If we are in a bad state due to figure-copying, try to recover gracefully:
if ~isvalid(hThis) || hFig ~= hThis.FigureHandle
    set(hFig,'WindowButtonDownFcn','');
    set(hFig,'WindowButtonUpFcn','');
    set(hFig,'WindowKeyPressFcn','');
    set(hFig,'WindowKeyReleaseFcn','');
    set(hFig,'KeyPressFcn','');
    set(hFig,'KeyReleaseFcn','');
    set(hFig,'Pointer',get(0,'DefaultFigurePointer'));
    if ~graphicsversion(hFig,'handlegraphics')
       if isprop(hFig,'ScribeClearModeCallback')
           hFig.ScribeClearModeCallback = '';  
       end    
    else         
       setappdata(hFig,'ScribeClearModeCallback','');
    end
    return;
end

appdata = hThis.FigureState;

%If we typed on a UIControl object, return unless we are suspending the
%callback.
oldState = get(groot,'ShowHiddenHandles');
set(groot,'ShowHiddenHandles','on');
h = get(hFig,'CurrentObject');
set(groot,'ShowHiddenHandles',oldState);
if ~isempty(h) && (ishghandle(h,'uicontrol') || ishghandle(h,'uitable'))
    if ~hThis.UIControlInterrupt
        return;
    end
end

%Execute the specified callback function
hgfeval(newKeyPressFcn,hFig,evd);

%Disable any button functions on the object we typed on. If there are
%multiple keys down, we need to be careful so as not to overwrite the
%keypress function.
if ishghandle(h)
    if ( isfield(appdata,'CurrentKeyPressObj') && ~isequal(appdata.CurrentKeyPressObj.Handle,h) ||...
            (isprop(h,'KeyPressFcn') && ~isempty(get(h,'KeyPressFcn'))))
        appdata.CurrentKeyPressObj.Handle = h;
        if isprop(h,'KeyPressFcn') && ~ishghandle(h,'figure')
            appdata.CurrentKeyPressObj.KeyPressFcn = get(h,'KeyPressFcn');
            set(h,'KeyPressFcn',[]);
        else
            appdata.CurrentKeyPressObj.KeyPressFcn = [];
        end
    end
else
    appdata.CurrentKeyPressObj.Handle = [];
end

hThis.FigureState = appdata;
