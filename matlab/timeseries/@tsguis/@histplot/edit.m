function edit(view,h)

% Copyright 2004-2012 The MathWorks, Inc.

%% Initialize prop editor
h.initialize(view)

%% Add panels
h.axespanel(view,'Y');
s = struct('charlist',{{getString(message('MATLAB:timeseries:tsguis:timeplot:Mean')),'tsguis.histMeanData','tsguis.histMeanView';...
    getString(message('MATLAB:timeseries:tsguis:timeplot:Median')),'tsguis.histMedianData','tsguis.histMeanView'}},...
    'additionalDataProps',{{}},'additionalDataPropDefaults',...
    {{}},'additionalHeadings',{{}});
h.charpanel(view,s);
view.binpnl(h);