function h = recorder
% Returns singleton instance of @recorder class

%   Copyright 1986-2005 The MathWorks, Inc.

mlock
persistent thisrecorder;

if isempty(thisrecorder) || ~ishandle(thisrecorder)
    thisrecorder = tsguis.recorder;
end

h =  thisrecorder;
