function schema
% Defines properties for @mergedlg class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'mergedlg',findclass(p,'viewdlg'));

%% Public properties
%schema.prop(c,'EditLock','on/off');





