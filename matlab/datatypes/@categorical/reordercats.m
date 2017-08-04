function a = reordercats(a,newCategories)
%REORDERCATS Reorder categories in a categorical array.
%   B = REORDERCATS(A) reorders the categories in the categorical array A to be
%   in alphanumeric order.
%
%   B = REORDERCATS(A,NEWORDER) reorders the categories in the categorical array
%   A.  NEWORDER is a cell array of strings that specifies the new order.
%   NEWORDER must be a permutation of CATEGORIES(A).
%
%   The order of the categories in an ordinal categorical array affects is used
%   by the <, <=, >, and >= relational operators, and by the MIN and MAX
%   methods.  Arrays that are not ordinal are not comparable with the relational
%   inequality operators, and the order of their categories has no mathematical
%   significance.
%
%   See also CATEGORIES, ADDCATS, REMOVECATS, ISCATEGORY, MERGECATS, RENAMECATS.

%   Copyright 2013 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWORDER'));
end

if nargin < 2 % put in alphabetic order
    [newCategories,iconvert] = sort(a.categoryNames);
    convert(iconvert,1) = 1:length(newCategories);
else % put in specified order
    newCategories = checkCategoryNames(newCategories,2); % error if duplicates

    [tf,convert] = ismember(a.categoryNames,newCategories);
    if (length(newCategories) ~= length(a.categoryNames)) || ~all(tf)
    error(message('MATLAB:categorical:reordercats:InvalidNeworder'));
    end
end

convert = cast([0; convert],categorical.codesClass); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1), size(a.codes));
a.categoryNames = newCategories;
