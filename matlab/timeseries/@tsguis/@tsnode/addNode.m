function hOut = addNode(this, varargin)
% Overloaded addNode so that uitreenodes are connected

%   Copyright 2004-2008 The MathWorks, Inc.

leaf = commonAddNode(this,varargin{:});

%have the tsstructurechange event fired
V = [];
try
    V = this.getRoot;
catch
    V = [];
end
if ~isempty(V) && ~strcmp(class(this),'tsexplorer.Workspace')
    myEventData = tsexplorer.tstreeevent(V,'add',leaf);
    V.fireTsStructureChangeEvent(myEventData,leaf.constructNodePath);
end

if nargout>0
    hOut = leaf;
end