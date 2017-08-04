function schema
%  SCHEMA  Defines properties for @regLineData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'regLineData', superclass);

% Public attributes
schema.prop(c, 'Slopes', 'MATLAB array'); % Line slopes
schema.prop(c, 'Biases', 'MATLAB array'); % Line biases