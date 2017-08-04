function hOut = commonAddNode(this, varargin)
% called by addNode so that uitreenodes are connected

% Copyright 2005-2011 The MathWorks, Inc.

% If no leaf is supplied, add a default child
if isempty( varargin )
  leaf = this.createChild;
else
  leaf = varargin{1};
end

if isa( leaf, 'tsexplorer.node' )
  connect( leaf, this, 'up' );
  %drawnow
  %this.TreeNode.add(leaf.TreeNode);
elseif isempty(leaf)
  % removed
  % warning( 'Leaf node is empty.' )
else
  error(message('MATLAB:tsexplorer:node:commonAddNode:leafNotofTypeExplorerNode', class( leaf )))
end

hOut = leaf;
