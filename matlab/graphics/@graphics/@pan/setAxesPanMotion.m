function setAxesPanMotion(hThis,hAx,style)
% Given an axes, determine the style of pan allowed

% Copyright 2006-2009 The MathWorks, Inc.

if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:pan:InvalidInputAxes'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(handle(hThis.FigureHandle),handle(hFig))
        error(message('MATLAB:graphics:pan:invalidaxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'pan');
    hBehavior.Style = style;
end