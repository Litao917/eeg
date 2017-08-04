function L = getlinks(this)
%GETLINKS  Gathers data link variables.
%
%   L = GETLINKS(D) returns the list L of data link
%   variables in the root node D.

%   Copyright 1986-2004 The MathWorks, Inc.
% L = get(this.Children_,{'Alias'});
% L = cat(1,L{:});
L = this.Cache_.Links;
