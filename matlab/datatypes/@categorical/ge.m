function t = ge(a,b)
%GE Greater than or equal to for ordinal categorical arrays.
%   TF = GE(A,B) returns a logical array the same size as the ordinal
%   categorical arrays A and B, containing logical 1 (true) where the elements
%   of A are greater than or equal to those of B, and logical 0 (false)
%   otherwise.  Either A or B may also be a cell array of strings.
%
%   Categorical arrays that are not ordinal can not be compared for greater than
%   or equal to inequality.
%
%   TF = GE(A,S) or TF = GE(S,A), where S is a character string, returns a
%   logical array the same size as A, containing logical 1 (true) where the
%   elements of A are greater than or equal to the category S.  S must be the
%   name of one of the categories in A.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  GE returns logical 0 (false) where
%   elements of A or B are undefined.
%
%   See also EQ, NE, LE, LT, GT.

%   Copyright 2006-2013 The MathWorks, Inc. 

[acodes,bcodes] = reconcileCategories(a,b,true);

% undefined elements cannot be greater than or equal to anything
t = (acodes >= bcodes) & (bcodes ~= 0);
