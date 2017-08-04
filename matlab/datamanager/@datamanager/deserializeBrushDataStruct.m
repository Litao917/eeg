function deserializeBrushDataStruct(brushDataStruct,gObj,extraPVPairs)
% This undocumented function may be removed in a future release.

% Deserialize the data properties of a @series so that data editing
% operations such as removing brushed data can be undone.

% Copyright 2013 The MathWorks, Inc.

xdata = brushDataStruct.Xdata;
ydata = brushDataStruct.Ydata;
zdata = brushDataStruct.Zdata;
if nargin<=2
    extraPVPairs = {};
end
if isempty(zdata)
    if ~isempty(findprop(handle(gObj),'XDataMode')) && ...
            strcmp(get(gObj,'XDataMode'),'auto')
        set(gObj,'YData',ydata,extraPVPairs{:});
    else
        set(gObj,'XData',xdata,'YData',ydata,extraPVPairs{:});
    end
else
    if ~isempty(findprop(handle(gObj),'XDataMode')) && ...
            strcmp(get(gObj,'XDataMode'),'auto')
        set(gObj,'YData',ydata,'ZData',zdata,extraPVPairs{:});
    else
        set(gObj,'XData',xdata,'YData',ydata,'ZData',zdata,extraPVPairs{:});
    end
end

