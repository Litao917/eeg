function str = maketip(this,tip,info)
%MAKETIP  Build data tips for eventCharView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2011 The MathWorks, Inc.

ind = find(strcmp(info.Data.EventName,get(info.Carrier.DataSrc.Timeseries.Events,{'Name'})));
str = '';
if ~isempty(ind)
    evtimestr = info.Carrier.DataSrc.Timeseries.Events(ind(1)).getTimeStr(...
        info.Carrier.Parent.TimeUnits);
    str = {sprintf(getString(message('MATLAB:tsguis:eventCharView:maketip:EventTime',info.Carrier.Name,...
        info.Data.EventName,evtimestr{1})))};
    TipText = str;
end