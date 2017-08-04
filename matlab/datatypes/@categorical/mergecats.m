function a = mergecats(a,oldCategories,newCategory)
%MERGECATS Merge categories in a categorical array.
%   B = MERGECATS(A,OLDCATEGORIES,NEWCATEGORY) merges two or more categories in
%   the categorical array A into a single new category. OLDCATEGORIES is a cell
%   array of strings that specifies the categories to be merged.  Any elements
%   of A whose value is a category in OLDCATEGORIES are assigned the category
%   NEWCATEGORY in the corresponding elements of B. NEWCATEGORY is a character
%   string that specifies the new category.
%
%   B = MERGECATS(A,CATEGORIES) merges the categories specified by the cell
%   array of strings CATEGORIES into the first specified category, CATEGORIES{1}.
%   Any elements of A whose value is a category in CATEGORIES are assigned that
%   category.
%
%   See also CATEGORIES, ADDCATS, REMOVECATS, ISCATEGORY, RENAMECATS, REORDERCATS.

%   Copyright 2013 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLD,NEW'));
end

oldCategories = checkCategoryNames(oldCategories,1); % remove any duplicates
isOrdinal = a.isOrdinal;

% Find the codes for the categories that will be merged. Ignore anything in
% oldCategories that didn't match a category in A.
[~,oldCodes] = ismember(oldCategories,a.categoryNames);
oldCodes(oldCodes == 0) = [];
if isempty(oldCodes), return, end

if nargin < 3
    newCategory = oldCategories{1};
elseif ischar(newCategory) && isrow(newCategory)
    newCategory = strtrim(newCategory);
    if strcmp(categorical.undefLabel,newCategory)
        error(message('MATLAB:categorical:mergecats:UndefinedLabel', categorical.undefLabel));
    elseif isempty(newCategory)
        error(message('MATLAB:categorical:mergecats:InvalidNewCategory'));
    end
else
    error(message('MATLAB:categorical:mergecats:InvalidNewCategory'));
end

convert = 1:length(a.categoryNames);

% The merged category may be an existing category, or may be a new category.
newCode = find(strcmp(newCategory,a.categoryNames)); % possibly empty
if isempty(newCode) || any(newCode==oldCodes)
    % Merging old categories to either a new category, or to one in that group.  The
    % merged category's internal code will reuse the lowest of the old codes.  Name
    % the merged category, with what may be a new or an old name.
    [newCode,j] = min(oldCodes); oldCodes(j) = [];
    a.categoryNames{newCode} = newCategory;
else
    % Merging old categories to an existing category not in that group.  Already have
    % the internal code, and the name is already correct.
end

% Cannot merge nonconsecutive ordinal categories unless they're being merged to
% one in the middle.
if isOrdinal && any(diff(sort([oldCodes; newCode]))~=1)
    error(message('MATLAB:categorical:mergecats:NonconsecutiveCategories'));
end

% Remove the remaining old categories from A
a.categoryNames(oldCodes) = [];

% Merge the codes for the old categories to the new category, and shift the
% codes for the existing categories down.
offset = zeros(size(convert));
offset(oldCodes) = 1;
offset = cumsum(offset);
convert = convert - offset;
convert(oldCodes) = convert(newCode);
convert = cast([0 convert],categorical.codesClass); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1),size(a.codes));
