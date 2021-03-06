function t = eq(a,b)
%EQ Equality for categorical arrays.
%   TF = EQ(A,B) returns a logical array the same size as the categorical arrays
%   A and B, containing logical 1 (true) where the corresponding elements of A
%   and B are equal, and logical 0 (false) otherwise.  Either A or B may also be
%   a cell array of strings.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the test is performed by comparing the
%   category names of each pair of elements.
%
%   TF = EQ(A,S) or TF = EQ(S,A), where S is a character string, returns a
%   logical array the same size as A, containing logical 1 (true) where the
%   corresponding elements of A are equal to S.
%
%   Undefined elements are not comparable to any other categorical values,
%   including other undefined elements.  EQ returns logical 0 (false) where
%   elements of A or B are undefined.
%
%   See also NE.

%   Copyright 2006-2013 The MathWorks, Inc. 

[acodes,bcodes] = reconcileCategories(a,b,false);

% undefined elements cannot be equal to anything
t = (acodes == bcodes) & (acodes ~= 0);

