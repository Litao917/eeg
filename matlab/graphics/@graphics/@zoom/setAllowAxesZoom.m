function setAllowAxesZoom(hThis,hAx,flag)
% Given an axes, determine whether zoom is allowed

% Copyright 2006-2009 The MathWorks, Inc.

if ~islogical(flag)
    if ~all(flag==0 | flag==1)
        error(message('MATLAB:zoom:InvalidInputZeroOne'))
    end
end
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
    hBehavior = hggetbehavior(hAx(i),'zoom');
    hBehavior.Enable = flag;
end