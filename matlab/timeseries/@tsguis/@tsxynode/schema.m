function schema
% Defines properties for @tsxynode class which represents
% spectral views of time series
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tsxynode',findclass(p,'viewnode'));

% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';
schema.prop(c,'Timeseries1','MATLAB array');
schema.prop(c,'Timeseries2','MATLAB array');



