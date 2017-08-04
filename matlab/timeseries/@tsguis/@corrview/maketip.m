function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @xyview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2011 The MathWorks, Inc.

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
strTimeseries = getString(message('MATLAB:tsguis:corrview:maketip:TimeSeries'));
str{1,1} = sprintf('%s: %s',strTimeseries,r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1) | ShowFlag
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end
strFrequency = getString(message('MATLAB:tsguis:corrview:maketip:Frequency'));
strMagnitude = getString(message('MATLAB:tsguis:corrview:maketip:Magnitude'));
str{end+1,1} = sprintf('%s (%s): %0.3g', strFrequency, AxGrid.XUnits,tip.Position(1));
str{end+1,1} = sprintf('%s (%s): %0.3g',...
  strMagnitude,AxGrid.YUnits{1},tip.Position(2));

