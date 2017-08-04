function setTimeProperty(h,prop,value)

% Copyright 2005 The MathWorks, Inc.

%% Access method used by timereset panel to set the timemetadata properties
thisTimeInfo = h.Tscollection.TimeInfo;
eval(['thisTimeInfo.' prop ' = value;']);
h.Tscollection.TimeInfo = thisTimeInfo;
