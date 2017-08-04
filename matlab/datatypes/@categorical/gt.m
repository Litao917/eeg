function t = gt(a,b)
%GT Greater than for ordinal categorical arrays.
%   TF = GT(A,B) returns a logical array the same size as the ordinal
%   categorical arrays A and B, containing logical 1 (true) where the elements
%   of A are greater than those of B, and logical 0 (false) otherwise.  A and B
%   must have the same sets of categories, including their order.  Either A or B
%   may also be a cell array of strings.
%
%   Categorical arrays that are not ordinal can not be compared for greater than
%   inequality.
%
%   TF = GT(A,S) or TF = GT(S,A), where S is a character string, returns a
%   logical array the same size as A, containing logical 1 (true) where the
%   elements of A are greater than the category S.  S must be the name of one of
%   the categories in A.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  GE returns logical 0 (false) where
%   elements of A or B are undefined.
%
%   See also EQ, NE, GE, LE, LT.

%   Copyright 2006-2013 The MathWorks, Inc. 

[acodes,bcodes] = reconcileCategories(a,b,true);

% undefined elements cannot be greater than anything
t = (acodes > bcodes) & (bcodes ~= 0);
