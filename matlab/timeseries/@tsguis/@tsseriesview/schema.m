function schema
% Defines properties for @seriesview class which represents
% views of time series as plots or in table form.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tsseriesview',findclass(p,'viewnode'));


% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';
p = schema.prop(c,'Calendar','MATLAB array');

%% Char listener array. Used to keep the characteristic table
%% synced with the char visibility
schema.prop(c,'CharListeners','MATLAB array');


