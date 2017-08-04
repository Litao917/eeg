function timercb(varargin)
%TIMERCB Wrapper for timer object callback.
%
%   See also TIMER
%

%    Copyright 2004 The MathWorks, Inc.

%Create a timer object out of the JavaTimer, and then call the object
%timercb.
h = handle(varargin{1});
t = timer(h);
timercb(t, varargin{2:end});

