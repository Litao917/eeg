function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2012 The MathWorks, Inc.
r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Ensure zstackminimum is set to at least 10 in case this tip was created 
% with hg
set(tip,'zstackminimum',21,'EnableZStacking',true);

str = {getString(message('MATLAB:timeseries:tsguis:regLineView:RegressionLine'))};
[RowNames,ColNames] = getrcname(info.Carrier);
str{end+1,1} = [RowNames{info.Row} '-' ColNames{info.Col}];
slopeStr = getString(message('MATLAB:timeseries:tsguis:regLineView:Slope'));
biasStr = getString(message('MATLAB:timeseries:tsguis:regLineView:Bias'));
str{end+1,1} = sprintf('%s %0.2g',slopeStr,info.Data.Slopes(info.Row,info.Col));
str{end+1,1} = sprintf('%s %0.2g',biasStr,info.Data.Biases(info.Row,info.Col));
TipText = str;
