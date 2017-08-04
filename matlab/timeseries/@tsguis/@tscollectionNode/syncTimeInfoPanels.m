function syncTimeInfoPanels(h,varargin)
% sync the time info on the tscollectionNode viewer panel with the
% underlying tscollection object. The two entities that need to be updated
% are the time vector table and the display of current time
% characteristics.
% This is equivalent of the syntable method of the tsnode, but it applies
% only to the time-specific information. Method TSTABLE, which calls this
% method, syncs the whole panel.

%   Copyright 2005-2008 The MathWorks, Inc.

V = varargin;
h.refreshChildrenData(V{:});

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

h.tscollectionCurrentTimeDisplay(V{:});