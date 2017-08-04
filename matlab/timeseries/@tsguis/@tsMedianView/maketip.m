function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2012 The MathWorks, Inc.
r = info.Carrier;
AxGrid = info.View.AxesGrid;
str = {getString(message('MATLAB:timeseries:tsguis:tsMedianView:Median',r.Name))};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:tsMedianView:Column',info.Row)); 
end
str{end+1,1} = sprintf('%0.2g',info.Data.MeanValue(info.Row));
TipText = str;