function str = maketip(this,tip,info)
%MAKETIP  Build data tips for tsCharViewView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2012 The MathWorks, Inc.
r = info.Carrier;
AxGrid = info.View.AxesGrid;
str0 = getString(message('MATLAB:timeseries:tsguis:tsCharVarView:TimeSeries',r.Name));
varianceFractionStr = sprintf('%0.4g', 100*(info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row))/info.Data.Variance(info.Row));
str1 = getString(message('MATLAB:timeseries:tsguis:tsCharVarView:VarianceFraction', varianceFractionStr));
varianceStr = sprintf('%0.4g',info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row));
str2 = getString(message('MATLAB:timeseries:tsguis:tsCharVarView:Variance', varianceStr));
standardDeviationStr = sprintf('%0.4g', sqrt(info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row)));
str3 = getString(message('MATLAB:timeseries:tsguis:tsCharVarView:StandardDeviation', standardDeviationStr));
str = {[str0,str1,str2,str3]};

if length(info.Data.Variance)>1
    str{end+1,1} = getString(message('MATLAB:timeseries:tsguis:tsCharVarView:Column',info.Row));
end
