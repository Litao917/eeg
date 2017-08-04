function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @bodeview curves.
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

% Create tip text
if length(r.RowIndex)>1
    str{1,1} = getString(message('MATLAB:timeseries:tsguis:specview:TimeSeriesColumn',r.Name,info.Row));
else
    str{1,1} = getString(message('MATLAB:timeseries:tsguis:specview:TimeSeries',r.Name));
end

[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1)
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end
position1 =  sprintf('%0.3g', tip.Position(1));
str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:specview:Frequency', ...
    AxGrid.XUnits, position1));
position2 =  sprintf('%0.3g', tip.Position(2));
str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:specview:Magnitude',...
  position2));

