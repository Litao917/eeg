function str = maketip(this,tip,info)
%MAKETIP  Build data tips for eventCharView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2011 The MathWorks, Inc.

r = info.Carrier;
AxGrid = info.View.AxesGrid;

str = {getString(message('MATLAB:tsguis:histMeanView:maketip:TimeSeries',r.Name))};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = getString(message('MATLAB:tsguis:histMeanView:maketip:ColumnNumber',info.Row)); 
end
%% Workaround to avoid creating a separate view class for median
if isa(info.Data,'tsguis.histMedianData')
    strMedian = getString(message('MATLAB:tsguis:histMeanView:maketip:Median'));
    str{end+1,1} = sprintf('%s: %0.2g',strMedian,info.Data.MeanValue(info.Row,info.Col)); 
else    
    strMean = getString(message('MATLAB:tsguis:histMeanView:maketip:Mean'));
    str{end+1,1} = sprintf('%s: %0.2g',strMean,info.Data.MeanValue(info.Row,info.Col));
end
TipText = str;