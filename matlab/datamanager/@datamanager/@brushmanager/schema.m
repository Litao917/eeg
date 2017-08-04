function schema

% Copyright 2008-2010 The MathWorks, Inc.

mlock;

% Register class 
c = schema.class(findpackage('datamanager'),'brushmanager');

% Structure of variables and selections
schema.prop(c,'SelectionTable','MATLAB array');
schema.prop(c,'VariableNames','MATLAB array');
schema.prop(c,'DebugMFiles','MATLAB array');
schema.prop(c,'DebugFunctionNames','MATLAB array');
schema.prop(c,'ArrayEditorVariables','MATLAB array');
schema.prop(c,'ArrayEditorSubStrings','MATLAB array');
schema.prop(c,'UndoData','MATLAB array');
schema.prop(c,'ApplicationData','MATLAB array');
prop.FactoryValue = false;
