function schema
%  SCHEMA  Defines properties for @eventCharData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'histMeanData', superclass);

% Public attributes
schema.prop(c, 'MeanValue', 'MATLAB array'); % Mean Value
