function h = tsviewer
% Returns singleton instance of @tsviewer

%   Copyright 2005 The MathWorks, Inc.

mlock
persistent TSVIEWER;

if isempty(TSVIEWER) || ~ishandle(TSVIEWER)
    TSVIEWER = tsguis.tsviewer;
end

h =  TSVIEWER;