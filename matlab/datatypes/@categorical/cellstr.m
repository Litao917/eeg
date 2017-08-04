function b = cellstr(a)
%CELLSTR Convert categorical array to cell array of strings.
%   B = CELLSTR(A) converts the categorical array A to a cell array of strings.
%   Each element of B contains the category name for the corresponding element
%   of A.
%
%   See also CHAR, CATEGORIES.

%   Copyright 2006-2013 The MathWorks, Inc. 

names = [categorical.undefLabel; a.categoryNames];
b = reshape(names(a.codes+1),size(a.codes));
