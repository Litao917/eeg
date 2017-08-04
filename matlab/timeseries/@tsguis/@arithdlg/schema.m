function schema
% Defines properties for @arithdlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'arithdlg');

%% Public properties

%% Visibility
p = schema.prop(c,'Visible','on/off');
p.FactoryValue = 'on';

%% Handles
schema.prop(c,'Handles','MATLAB array');

%% Handles
schema.prop(c,'Figure','MATLAB array');

%% Listeners
schema.prop(c,'Listeners','MATLAB array');





