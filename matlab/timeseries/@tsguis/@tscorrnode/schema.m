function schema
% Defines properties for @tsxcorrnode class 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tscorrnode',findclass(p,'viewnode'));

% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';
schema.prop(c,'Timeseries1','MATLAB array');
schema.prop(c,'Timeseries2','MATLAB array');




