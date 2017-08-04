function schema
%SCHEMA  Class definition for @tssource (time series response source).

%  Author(s): 
%  Copyright 1986-2004 The MathWorks, Inc.

% Register class (subclass)
pkg = findpackage('tsguis');
superclass = findclass(findpackage('wrfc'),'datasource');
c = schema.class(pkg, 'tssource', superclass);

%% Time series which generates data
schema.prop(c, 'Timeseries', 'handle');

%% Additional time series for XY plots (optional)
schema.prop(c, 'Timeseries2', 'handle');

%% Mask for hiding individual columns 
schema.prop(c, 'Mask', 'MATLAB array'); 

