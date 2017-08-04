function h = brushmanager

% Copyright 2008-2010 The MathWorks, Inc.

% Brushmanager is a singleton
mlock
persistent bManager;
if isempty(bManager)
    bManager = datamanager.brushmanager;    
    com.mathworks.page.datamgr.brushing.ArrayEditorManager.addArrayEditorListener;
end
h = bManager;
