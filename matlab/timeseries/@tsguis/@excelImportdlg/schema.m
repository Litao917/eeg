function schema
% SCHEMA Defines properties for @excelImportdlg class.
%
%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc. 

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'excelImportdlg',findclass(p,'abstractTSIOdlg'));

%% Public properties

%% Parameters for determine the positions of all the GUI components 
p = schema.prop(c,'IOData','MATLAB array');
