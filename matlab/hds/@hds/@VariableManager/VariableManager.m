function this = VariableManager
% Returns handle of Variable Manager object.

%   Copyright 1986-2004 The MathWorks, Inc.
mlock
persistent h
           
if isempty(h)
    % Create singleton class instance (first time an HDS dataset is
    % created)
    h = hds.VariableManager;
end

this = h;

