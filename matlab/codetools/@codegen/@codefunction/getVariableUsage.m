function [hRequire, hProvide] = getVariableUsage(hFunc)
%getVariableUsage Return the required and provided variables
%
%  [hRequired, hProvided] = getVariableUsage(hFunc) returns the set of
%  inputs that are required and the set of outputs that this function call
%  will provide.

%  Copyright 2012 The MathWorks, Inc.

% All inputs are required
hRequire = hFunc.Argin;

% Only outputs that are not also inputs are provided
hProvide = hFunc.Argout;
if ~isempty(hProvide)
    hProvide = setdiff(hProvide, hFunc.Argin);
end
