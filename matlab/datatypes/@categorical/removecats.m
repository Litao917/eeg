function a = removecats(a,oldCategories)
%REMOVECATS Remove categories from a categorical array.
%   B = REMOVECATS(A) removes unused categories from the categorical array A,
%   that is, categories that not are actually present as the value of some
%   element of A.  B is a categorical array with the same size and values as A,
%   but whose set of categories may be smaller.
%
%   B = REMOVECATS(A,OLDCATEGORIES) removes the categories specified by
%   OLDCATEGORIES from the categorical array A.  OLDCATEGORIES is a string or a
%   cell array of strings. REMOVECATS removes the categories, but does not
%   remove elements. Elements of B that correspond to elements of A whose values
%   are in OLDCATEGORIES are undefined.
%
%   See also CATEGORIES, ADDCATS, ISCATEGORY, MERGECATS, RENAMECATS, REORDERCATS.

%   Copyright 2013 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLD'));
end

if nargin < 2
    % Find any unused codes in A.
    codehist = histc(a.codes(:),1:length(a.categoryNames));
    oldCodes = find(codehist == 0);
else
    oldCategories = checkCategoryNames(oldCategories,1); % remove any duplicates
    
    % Find the codes for the categories that will be dropped.
    oldCodes = zeros(1,length(oldCategories));
    for i = 1:length(oldCategories)
        found = find(strcmp(oldCategories{i},a.categoryNames));
        if ~isempty(found) % a unique match
            oldCodes(i) = found;
        end
    end
    
    % Ignore anything in oldCategories that didn't match a category of A.
    if any(oldCodes == 0)
        oldCodes(oldCodes == 0) = [];
    end
    
    % Some elements of A may have become undefined.
end

convert = 1:length(a.categoryNames);

% Remove the old categories from A.
a.categoryNames(oldCodes) = [];

% Translate the codes for the categories that haven't been dropped.
dropped = zeros(size(convert));
dropped(oldCodes) = 1; 
convert = convert - cumsum(dropped);
convert(dropped>0) = 0;
convert = cast([0 convert],categorical.codesClass); % there may be zeros in a.codes
a.codes = reshape(convert(a.codes+1),size(a.codes));
