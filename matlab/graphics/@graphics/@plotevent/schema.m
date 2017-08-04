function schema()
%SCHEMA Plotting function done event schema

%   Copyright 1984-2010 The MathWorks, Inc. 

classPkg = findpackage('graphics');
basePkg = findpackage('handle');
baseCls = basePkg.findclass('EventData');

%define class
hClass = schema.class(classPkg , 'plotevent', baseCls);
hClass.description = 'A high-level plotting function event';

schema.prop(hClass, 'ObjectsCreated', 'MATLAB array');
schema.prop(hClass, 'Figure', 'MATLAB array');
