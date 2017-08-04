function updateNodeNameCallback(node,newName)
%Callback to the name-change event of the timeseries data object, which
% the node listens to.
% The listener that calls this function is typically created in the data
% object's createTstoolNode method.

%   Copyright 2005 The MathWorks, Inc. 

if isempty(node.getParentNode) %this is not a data node
    return;
end

oldnodepath = node.constructNodePath;
node.Label = newName;
newnodepath = node.constructNodePath;
ed = tsexplorer.tstreeevent(node.getRoot,'rename',node);

%Have the event fired
node.getRoot.fireTsStructureChangeEvent(ed,{oldnodepath,newnodepath});

