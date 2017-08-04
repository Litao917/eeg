function modeKeyPressFcn(hMode,hFig,evd,hThis,newKeyPressFcn)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2007-2010 The MathWorks, Inc.

%If we are in a bad state due to figure-copying, try to recover gracefully:
if ~ishandle(hThis) || hFig ~= hThis.FigureHandle
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

hgfeval(newKeyPressFcn,hFig,evd);