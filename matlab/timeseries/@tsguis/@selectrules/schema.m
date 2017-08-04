function schema
% Defines properties for @selectrules class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'selectrules',findclass(p,'viewdlg'));

%% Public properties

%% Rule objects
schema.prop(c,'Rules','MATLAB array');
schema.prop(c,'Calendar','MATLAB array');








