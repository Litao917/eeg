function schema
% Defines properties for derived specplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('tsguis');
% Register class 
c = schema.class(p,'specplot',findclass(p,'tsplot'));

% Plulic properties
% Accumulate or not
schema.prop(c, 'Cumulative', 'on/off');

%% AxesTable handle for Proeprty Editor Panels
schema.prop(c, 'PropEditor', 'MATLAB array');