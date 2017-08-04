function [c,i] = setdiff(a,b,varargin)
%SETDIFF Set difference for categorical arrays.
%   C = SETDIFF(A,B) for categorical arrays A and B, returns the values in A
%   that are not in B with no repetitions.  Either A or B may also be a cell
%   array of strings.  C is sorted.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names. In this case, C's categories are the sorted union of A's and
%   B's categories.
%
%   C = SETDIFF(A,B,'rows') for categorical matrices A and B with the same
%   number of columns, returns the rows from A that are not in B.  Either A or B
%   may also be a cell array of strings.  The rows of the matrix C are in sorted
%   order.
%
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that
%   C = A(IA). If there are repeated values in A that are not in B, then
%   the index of the last occurrence of each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows') also returns an index vector IA such that
%   C = A(IA,:).
%
%   [C,IA] = SETDIFF(A,B,'stable') for categorical arrays A and B, returns the
%   values of C in the order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'sorted') returns the values of C in sorted order.
%   If A is a row vector, then C will be a row vector as well, otherwise C
%   will be a column vector. IA is a column vector. If there are repeated
%   values in A that are not in B, then the index of the first occurrence of
%   each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
% 
%   SETDIFF(A,B,'legacy') and SETDIFF(A,B,'rows','legacy') preserve the behavior
%   of the SETDIFF function from R2012b and prior releases.
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.

%   Copyright 2006-2013 The MathWorks, Inc. 

import matlab.internal.tableUtils.isStrings

narginchk(2,Inf);

if ~isa(a,'categorical') || ~isa(b,'categorical')
    if isStrings(a)
        a = strings2categorical(a,b);
    elseif isStrings(b)
        b = strings2categorical(b,a);
    else
        error(message('MATLAB:categorical:setmembership:TypeMismatch','SETDIFF'));
    end
elseif a.isOrdinal ~= b.isOrdinal
    error(message('MATLAB:categorical:setmembership:OrdinalMismatch','SETDIFF'));
end
isOrdinal = a.isOrdinal;
a = a(:); b = b(:);

acodes = a.codes;
cnames = a.categoryNames;
if isequal(b.categoryNames,cnames)
    bcodes = b.codes;
elseif ~isOrdinal
    % Convert b to a's categories, possibly expanding the set of categories
    % if neither array is protected.
    [bcodes,cnames] = convertCodes(b.codes,b.categoryNames,cnames,a.isProtected,b.isProtected);
else
    error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
end

if nargin > 2 && ~isStrings(varargin)
    error(message('MATLAB:categorical:setmembership:UnknownInput'));
end

% Set the code value for undefined elements to the largest integer.  setdiff
% will put one of these at the end if any are present in A but not B.
tmpCode = categorical.invalidCode; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode; %#ok<FNDSB>

try
    if nargout > 1
        [ccodes,i] = setdiff(acodes,bcodes,varargin{:});
    else
        ccodes = setdiff(acodes,bcodes,varargin{:});
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa)
    % There may or may not already be a single tmpCode at the end of ccodes
    k = length(ccodes) + (isempty(ccodes) || ccodes(end) ~= tmpCode);
    ccodes(k:k+length(undefsa)-1) = 0;
    if nargout > 1
        k = length(i) + (isempty(i) || acodes(i(end)) ~= tmpCode);
        i(k:k+length(undefsa)-1) = undefsa;
    end
end

c = a; % preserve subclass
c.codes = ccodes;
c.categoryNames = cnames;
