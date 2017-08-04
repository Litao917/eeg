function schema
% Defines properties for @newplotpanel class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc. 


%% Register class (subclass)
c = schema.class(findpackage('tsguis'),'newplotpanel');

%% Public properties
schema.prop(c,'Handles','MATLAB array');

%% Main panel
schema.prop(c,'Panel','MATLAB array');

%% Parent node
schema.prop(c,'Node','MATLAB array');

