function schema
%  SCHEMA  Defines properties for @eventCharData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'eventCharData', superclass);

% Public attributes
%schema.prop(c, 'Event', 'MATLAB array'); % Event
schema.prop(c, 'Time', 'MATLAB array'); 
schema.prop(c, 'Amplitude', 'MATLAB array'); 
schema.prop(c, 'EventName', 'MATLAB array'); % Event
