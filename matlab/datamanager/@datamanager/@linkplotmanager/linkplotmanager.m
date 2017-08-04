function h = linkplotmanager

%   Copyright 2007-2011 The MathWorks, Inc.

% Linkplotmanager is a singleton
mlock
persistent linkManager;

if isempty(linkManager)
    linkManager = datamanager.linkplotmanager;
    try 
        linkManager.LinkListener = com.mathworks.page.datamgr.linkedplots.LinkedVariableObserver;
        linkManager.LinkListener.activate;
    catch %#ok<CTCH>
        error(message('MATLAB:graphics:linkplotdata'));
    end
end
h = linkManager;
