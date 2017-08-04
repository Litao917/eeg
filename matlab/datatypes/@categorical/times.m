function c = times(a,b)
%TIMES Create a categorical array from the cartesian product of existing categories.
%   C = TIMES(A,B) returns a categorical array whose categories are the
%   cartesian product of the sets of categories in A and B, and whose elements
%   are each from the category formed from the combination of the categories of
%   the corresponding elements of A and B.  Either A or B may also be a cell
%   array of strings.
%
%   C = TIMES(A,B) is called for the syntax A .* B.
%
%   See also CATEGORICAL/CATEGORICAL.

%   Copyright 2006-2013 The MathWorks, Inc.

import matlab.internal.tableUtils.isStrings

% Accept 1 as a valid "identity element".
if isequal(a,1)
    c = b;
    return;
elseif isequal(b,1)
    c = a;
    return;
elseif ~isa(a,'categorical') || ~isa(b,'categorical')
    if isStrings(a)
        if ischar(a), a = {a}; end
        acodes = zeros(size(a),categorical.codesClass);
        [anames,~,acodes(:)] = unique(strtrim(a));
        bnames = b.categoryNames; bcodes = b.codes;
        c = b;
        c.isOrdinal = b.isOrdinal;
        c.isProtected = b.isProtected;
    elseif isStrings(b)
        anames = a.categoryNames; acodes = a.codes;
        if ischar(b), b = {b}; end
        bcodes = zeros(size(b),categorical.codesClass);
        [bnames,~,bcodes(:)] = unique(strtrim(b));
        c = a;
        c.isOrdinal = a.isOrdinal;
        c.isProtected = a.isProtected;
    else
        error(message('MATLAB:categorical:times:TypeMismatch'));
    end
else
    anames = a.categoryNames; acodes = a.codes;
    bnames = b.categoryNames; bcodes = b.codes;
    c = a;
    c.isOrdinal = (a.isOrdinal && b.isOrdinal);
    c.isProtected = (a.isProtected || b.isProtected);
end

na = length(anames);
nb = length(bnames);
if na*nb > categorical.maxNumCategories
    error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
end

anames = repmat(anames(:)',nb,1); anames = anames(:);
bnames = repmat(bnames(:)',1,na); bnames = bnames(:);
c.categoryNames = strcat(anames,{' '},bnames);
c.codes = bcodes + nb*(acodes-1);
