function schema
% Defines properties for derived specplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');
c = schema.class(p,'histplot',findclass(p,'tsplot'));

%% Public properties
p = schema.prop(c,'Bins','MATLAB array');
p.FactoryValue = 50;


