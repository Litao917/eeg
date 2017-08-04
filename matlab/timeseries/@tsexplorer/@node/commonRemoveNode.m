function commonRemoveNode(this, leaf)
% COMMONREMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.
% REMOVENODE methods of various nodes call this function.


% Copyright 2005-2011 The MathWorks, Inc.

children = setdiff(this.find('-depth',1),this);

% Is leaf really a child of this?
if any( children == leaf )

    %have the tsstructurechange event fired
    V = [];
    try
        V = this.getRoot;
    catch
        V = [];
    end
    % update cache only for data nodes
    if ~isempty(V) && ~isempty(this.getParentNode)
        myEventData = tsexplorer.tstreeevent(V,'remove',leaf);
        V.fireTsStructureChangeEvent(myEventData,leaf.constructNodePath);
    end

    % Disconnect from the tree
    disconnect( leaf )

    % Remove all listeners
    delete( leaf.TreeListeners( ishandle(leaf.TreeListeners) ) )
    leaf.TreeListeners = [];

    leaf.Listeners.deleteListeners;

    % Delete leaf node
    %delete( leaf );
elseif isa( leaf, 'tsexplorer.node' )
    warning(message('MATLAB:tsexplorer:node:commonRemoveNode:wrongLeafNode', leaf.Label, this.Label))
else
    error(message('MATLAB:tsexplorer:node:commonRemoveNode:leafNotofTypeExplorerNode', class( leaf )))
end
