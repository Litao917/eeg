function [tf,isInt] = isScalarInt(x,lower,upper)
%   T = ISSCALARINT(X) returns true if X is a scalar integer value, and false
%   otherwise.
%
%   T = ISSCALARINT(X,0) returns true if X is a non-negative scalar integer
%   value, and false otherwise.
%
%   T = ISSCALARINT(X,1) returns true if X is a positive scalar integer value,
%   and false otherwise.
%
%   T = ISSCALARINT(X,LOWER,UPPER) returns true if X is a scalar integer value
%   from LOWER to UPPER, and false otherwise.
%
%   [T,ISINT] = ISSCALARINT(X,...) returns true in ISINT if X is a scalar
%   integer value, even if it is not within the desired range.

%   Copyright 2013 The MathWorks, Inc.

if isscalar(x)
    isInt = isnumeric(x) && all(round(x(:)) == x(:));
    if nargin == 1
        tf = isInt;
    elseif nargin == 2
        tf = isInt && all(x(:) >= lower);
    else % nargin == 3
        tf = isInt && all((lower <= x(:)) & (x(:) <= upper));
    end
else
    tf = false;
    isInt = false;
end


