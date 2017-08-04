function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @timeview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2012 The MathWorks, Inc.

r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Clear all data tips on this line
dcm = datacursormode(ancestor(AxGrid.Parent,'figure'));
dc = dcm.DataCursors;
hosts = get(dc,{'Host'});
for j=1:length(hosts)
    if dc(j)~=tip
        dcm.removeDataCursor(dc(j));
    end
end

% Ensure zstackminimum is set to at least 10 in case this tip was created 
% with hg
set(tip,'zstackminimum',11,'EnableZStacking',true);

% Finalize Y data
Y = tip.Position(2);
AxGrid = info.View.AxesGrid;
if strcmp(AxGrid.YNormalization,'on')
   ax = getaxes(tip);
   Y = denormalize(info.Data,Y,get(ax,'XLim'),info.Row,info.Col);
end
   
% Create tip text
if length(r.RowIndex)>1
    str{1,1} = getString(message('MATLAB:timeseries:tsguis:timeview:TimeSeriesColumn',r.Name,info.Row));
else
    str{1,1} = getString(message('MATLAB:timeseries:tsguis:timeview:TimeSeries',r.Name));
end
if ~isempty(info.Carrier.Parent.startDate) && strcmp(info.Carrier.Parent.Absolutetime,'on')
    str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:timeview:Timedate',  ...
        datestr(tsunitconv('days',info.Carrier.Parent.TimeUnits)))*tip.Position(1)+...
        datenum(info.Carrier.Parent.StartDate),info.Carrier.Parent.TimeFormat);
else  
    tipPositionStr = sprintf('%0.3g', tip.Position(1));
    str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:timeview:Time', AxGrid.XUnits, tipPositionStr));
end
    YStr = sprintf('%0.3g', Y);
str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:timeview:Amplitude', YStr));


