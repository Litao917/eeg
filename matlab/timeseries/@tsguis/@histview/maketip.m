function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @histview curves.
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
if length(r.RowIndex)>1
    strTimeSeries = getString(message('MATLAB:tsguis:histview:maketip:TimeSeries'));
    strColumn = getString(message('MATLAB:tsguis:histview:maketip:Column'));
    str{1,1} = sprintf('%s: %s %s: %d',strTimeSeries,r.Name,strColumn,info.Row);
else
    strTimeSeries = getString(message('MATLAB:tsguis:histview:maketip:TimeSeries'));
    str{1,1} = sprintf('%s: %s',strTimeSeries,r.Name);
end

strCount = getString(message('MATLAB:tsguis:histview:maketip:Count'));
str{end+1,1} = sprintf('%s: %0.3g',strCount,tip.Position(2));
[junk,I] = min(abs(tip.Position(1)-info.Data.XData));
if I==1
    width = (info.Data.XData(2)-info.Data.XData(1))/2;
else
    width = (info.Data.XData(I)-info.Data.XData(I-1))/2;
end
strRange = getString(message('MATLAB:tsguis:histview:maketip:Range'));
strTo = getString(message('MATLAB:tsguis:histview:maketip:To'));
str{end+1,1} = sprintf('%s: %0.3g %s %0.3g',strRange,info.Data.XData(I)-width, ...
    strTo,info.Data.XData(I)+width);