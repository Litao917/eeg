function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'statsdlg');

%% Public proeprties
schema.prop(c, 'Timeseries', 'MATLAB array');
schema.prop(c, 'Srcnode', 'MATLAB array');
schema.prop(c, 'Listeners', 'MATLAB array');
schema.prop(c, 'Figure', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');
schema.prop(c, 'Visible', 'on/off');
schema.prop(c, 'tslisteners', 'MATLAB array');

