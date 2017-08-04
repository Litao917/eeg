function schema
% SCHEMA Defines properties for @excelImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2005 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'csvImportdlg',findclass(p,'excelImportdlg'));


