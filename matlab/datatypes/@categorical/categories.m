function l = categories(a)
%CATEGORIES Get a list of a categorical array's categories.
%   S = CATEGORIES(A) returns the list of categories in the categorical array A.
%   S is a cell array of strings.
%
%   S includes all categories in A, even those not appearing in any element of
%   A. To see the values actually present in elements of A, use UNIQUE.
%
%   See also UNiQUE, ADDCATS, REMOVECATS, ISCATEGORY, MERGECATS, RENAMECATS, REORDERCATS.

%   Copyright 2013 The MathWorks, Inc. 

l = a.categoryNames;
