function clear(this)
%CLEAR  Clears data.

%  Author(s): 
%  Copyright 1986-2004 The MathWorks, Inc.

%% Clear is a no-op for eventCharData since the timeresp method of the
%% @tssource needs the event property to match the event characteristics
%% with the events stored in the time series, so the event proeprty cannot
%% be cleared
