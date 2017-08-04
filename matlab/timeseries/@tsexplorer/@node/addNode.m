function hOut = addNode(this, varargin)
% Overloaded addNode so that uitreenodes are connected

%   Copyright 2004-2008 The MathWorks, Inc.

leaf = commonAddNode(this,varargin{:});
if nargout>0
    hOut = leaf;
end
