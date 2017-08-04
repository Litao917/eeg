function res = isAllowAxesZoom(hThis,hAx)
% Given an axes, determine whether zooming is allowed

%   Copyright 2013 The MathWorks, Inc.

res = true(length(hAx),1);
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
    hBehavior = hggetbehavior(hAx(i),'zoom','-peek');
    if ~isempty(hBehavior)
        res(i) = hBehavior.Enable;
    end
end