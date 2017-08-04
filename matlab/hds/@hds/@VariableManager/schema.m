function schema
% Defines properties for @VariableManager class.
%
%   Singleton class that maintains the variable pool and 
%   assigns a unique handle to each variable name.

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('hds'),'VariableManager');

% Private properties
p = schema.prop(c,'VarTable','MATLAB array');   
p.FactoryValue = struct;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
