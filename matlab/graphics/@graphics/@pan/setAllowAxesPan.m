function setAllowAxesPan(hThis,hAx,flag)
% Given an axes, determine whether pan is allowed

% Copyright 2006-2009 The MathWorks, Inc.

if ~islogical(flag)
    if ~all(flag==0 | flag==1)
        error(message('MATLAB:pan:InvalidInputZeroOne'))
    end
end
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
    hBehavior.Enable = flag;
end