function edit(this,h)

% Copyright 2004-2011 The MathWorks, Inc.

%% Initialize prop editor
h.initialize(this)

%% Add panels
h.axespanel(this,'X');
h.axespanel(this,'Y');
s = struct('charlist',{{getString(message('MATLAB:timeseries:tsguis:xyplot:BestFitLine')), ...
    'tsguis.regLineData','tsguis.regLineView'}},...
    'additionalDataProps',{{}},'additionalDataPropDefaults',{{}},'additionalHeadings',{{}});
h.charpanel(this,s);
h.Handles.TabPane.setName('XYPnl.TabPane');
