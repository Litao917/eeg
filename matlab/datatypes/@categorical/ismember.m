function [tf,loc] = ismember(a,b,varargin)
%ISMEMBER True for elements of a categorical array in a set.
%   LIA = ISMEMBER(A,B) for categorical arrays A and B, returns a logical array
%   of the same size as A containing true where the elements of A are in B and
%   false otherwise.  A or B may also be a category name or a cell array of
%   strings containing category names.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names.
%
%   LIA = ISMEMBER(A,B,'rows') for categorical matrices A and B with the same
%   number of columns, returns a logical vector containing true where the rows
%   of A are also rows of B and false otherwise.  A or B may also be a cell array
%   of strings containing category names.
%
%   [LIA,LOCB] = ISMEMBER(A,B) also returns an index array LOCB containing the
%   highest absolute index in B for each element in A which is a member of B
%   and 0 if there is no such index.
%
%   [LIA,LOCB] = ISMEMBER(A,B,'rows') also returns an index vector LOCB
%   containing the highest absolute index in B for each row in A which is a
%   member of B and 0 if there is no such index.
% 
%   ISMEMBER(A,B,'legacy') and ISMEMBER(A,B,'rows','legacy') preserve the
%   behavior of the ISMEMBER function from R2012b and prior releases.
%
%   See also ISCATEGORY, UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR.

%   Copyright 2006-2013 The MathWorks, Inc.

import matlab.internal.tableUtils.isstring
import matlab.internal.tableUtils.isStrings

narginchk(2,Inf);

if isa(a,'categorical')
    acodes = a.codes;
    if isa(b,'categorical')
        if a.isOrdinal ~= b.isOrdinal
            error(message('MATLAB:categorical:ismember:OrdinalMismatch'));
        elseif a.isOrdinal && ~isequal(a.categoryNames,b.categoryNames)
            error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
        end
        % Convert b to a's categories
        bcodes = convertCodes(b.codes,b.categoryNames,a.categoryNames);
    else
        if isstring(b)
            b = cellstr(b);
        elseif ~isStrings(b)
            error(message('MATLAB:categorical:ismember:TypeMismatch'));
        end
        [~,bcodes] = ismember(strtrim(b),a.categoryNames);
    end
else % ~isa(a,'categorical') && isa(b,'categorical')
    if isstring(a)
        a = cellstr(a);
    elseif ~isStrings(a)
        error(message('MATLAB:categorical:ismember:TypeMismatch'));
    end
    [~,acodes] = ismember(strtrim(a),b.categoryNames);
    bcodes = b.codes;
end

if nargin > 2 && ~isStrings(varargin)
    error(message('MATLAB:categorical:setmembership:UnknownInput'));
end

bcodes(bcodes==0) = categorical.invalidCode; % prevent zero codes for <undefined> from matching these
if nargout < 2
    tf = ismember(acodes,bcodes,varargin{:});
else
    [tf,loc] = ismember(acodes,bcodes,varargin{:});
end
