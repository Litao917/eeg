function removeNode(this, leaf)
% REMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.

% Author(s):  
% Revised: 
%   Copyright 2004-2005 The MathWorks, Inc.

this.commonRemoveNode(leaf);

