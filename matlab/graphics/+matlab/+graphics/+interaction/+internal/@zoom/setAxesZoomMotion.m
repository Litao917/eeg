function setAxesZoomMotion(hThis,hAx,style)
% Given an axes, determine the style of pan allowed

%   Copyright 2013 The MathWorks, Inc.

if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:zoom:InvalidInputAxes'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(hThis.FigureHandle,hFig)
        error(message('MATLAB:graphics:zoom:invalidaxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'zoom');
    hBehavior.Style = style;
end