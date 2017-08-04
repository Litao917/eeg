function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'datamergedlg',findclass(p,'mergedlg'));

