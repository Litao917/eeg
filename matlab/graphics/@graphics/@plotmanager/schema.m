function schema
%SCHEMA Plot manager schema

%   Copyright 1984-2011 The MathWorks, Inc.

mlock;

pk = findpackage('graphics');
cls = schema.class(pk,'plotmanager');

schema.event(cls,'PlotFunctionDone');
schema.event(cls,'PlotEditPaste');
schema.event(cls,'PlotEditBeforePaste');
schema.event(cls,'PlotSelectionChange');
