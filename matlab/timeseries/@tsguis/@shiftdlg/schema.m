function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'shiftdlg',findclass(p,'viewdlg'));

%% Public proeprties
schema.prop(c,'Unitlistener','MATLAB array');



