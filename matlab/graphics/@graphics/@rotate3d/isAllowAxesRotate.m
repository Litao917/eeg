function res = isAllowAxesRotate(hThis,hAx)
% Given an axes, determine whether panning is allowed

% Copyright 2006-2009 The MathWorks, Inc.

res = true(length(hAx),1);
if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:rotate3d:InvalidInputAxes'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(handle(hThis.FigureHandle),handle(hFig))
        error(message('MATLAB:graphics:rotate3d:invalidaxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'Rotate3d','-peek');
    if ~isempty(hBehavior)
        res(i) = hBehavior.Enable;
    end
end