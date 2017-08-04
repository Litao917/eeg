function [varargout] = subsrefRecurser(a,s)
%SUBSREFRECURSER Utility for overloaded subsref method in @table.

%   Copyright 2012 The MathWorks, Inc.

% Call builtin, to get correct dispatching even if b is a table object.
[varargout{1:nargout}] = subsref(a,s);
