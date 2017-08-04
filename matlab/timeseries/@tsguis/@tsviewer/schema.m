function schema
% Defines properties for @tsviewer class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2013 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');

%% Register class 
c = schema.class(p,'tsviewer');

%% Public properties
schema.prop(c,'TreeManager','MATLAB array');
schema.prop(c,'TSnode','MATLAB array');
schema.prop(c,'ViewsNode','MATLAB array');
schema.prop(c,'Clipboard','MATLAB array');
schema.prop(c,'StyleManager','MATLAB array');
schema.prop(c,'EventsNode','MATLAB array');
p = schema.prop(c,'MaxPlotLength','MATLAB array');
p.FactoryValue = 1e10;
schema.prop(c,'TSPathCache','MATLAB array');
p = schema.prop(c,'MDIGroupName','string');
p.FactoryValue = getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesPlots'));
p = schema.prop(c,'HelpEnabled','bool');
p.FactoryValue = true;
p = schema.prop(c,'DataTipsEnabled','bool');
p.FactoryValue = false;
schema.prop(c,'StyleDlg','MATLAB array');
p = schema.prop(c,'Listeners','MATLAB array');

%% If necessary create enumerated list of time units
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});
end
