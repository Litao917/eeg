function style = getAxesZoomMotion(hThis,hAx)
% Given an axes, determine the style of pan allowed

% Copyright 2006-2009 The MathWorks, Inc.

style = cell(length(hAx),1);
if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:zoom:InvalidInputAxes'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(handle(hThis.FigureHandle),handle(hFig))
        error(message('MATLAB:graphics:zoom:invalidaxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'zoom','-peek');
    if isempty(hBehavior)
        style{i} = 'both';
    else
        style{i} = hBehavior.Style;
    end
end