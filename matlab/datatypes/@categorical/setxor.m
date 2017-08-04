function [c,ia,ib] = setxor(a,b,varargin)
%SETXOR Set exclusive-or for categorical arrays.
%   C = SETXOR(A,B) for categorical arrays A and B, returns the values that are
%   not in the intersection of A and B with no repetitions.  Either A or B may
%   also be a cell array of strings.  C is sorted.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names. In this case, C's categories are the sorted union of A's and
%   B's categories.
%
%   C = SETXOR(A,B,'rows') for categorical matrices A and B with the same number
%   of columns, returns the rows that are not in the intersection of A and B.
%   Either A or B may also be a cell array of strings.  The rows of the matrix C
%   are in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that 
%   C is a sorted combination of the values A(IA) and B(IB). If there 
%   are repeated values that are not in the intersection in A or B then the
%   index of the last occurrence of each repeated value is returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of rows A(IA,:) and B(IB,:).
%
%   [C,IA,IB] = SETXOR(A,B,'stable') for categorical arrays A and B, returns
%   the values of C in the same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'sorted') returns the values of C in sorted
%   order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are repeated values that are not in the intersection of A and
%   B, then the index of the first occurrence of each repeated value is
%   returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
% 
%   SETXOR(A,B,'legacy') and SETXOR(A,B,'rows','legacy') preserve the behavior
%   of the SETXOR function from R2012b and prior releases.
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

%   Copyright 2006-2013 The MathWorks, Inc. 

import matlab.internal.tableUtils.isStrings

narginchk(2,Inf);

if ~isa(a,'categorical') || ~isa(b,'categorical')
    if isStrings(a)
        a = strings2categorical(a,b);
    elseif isStrings(b)
        b = strings2categorical(b,a);
    else
        error(message('MATLAB:categorical:setmembership:TypeMismatch','SETXOR'));
    end
elseif a.isOrdinal ~= b.isOrdinal
    error(message('MATLAB:categorical:setmembership:OrdinalMismatch','SETXOR'));
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

% Set the code value for undefined elements to the largest integer.  setxor
% will put one of these at the end if any are present in A but not B or in B
% but not A.
tmpCode = categorical.invalidCode; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,ia,ib] = setxor(acodes,bcodes,varargin{:});
    else
        ccodes = setxor(acodes,bcodes,varargin{:});
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa) || ~isempty(undefsb)
    % There may or may not already be a single tmpCode at the end of ccodes
    k = length(ccodes) + (ccodes(end) ~= tmpCode);
    ccodes(k:k+length(undefsa)+length(undefsb)-1) = 0;
    if nargout > 1
        k = length(ia) + (isempty(ia) || acodes(ia(end)) ~= tmpCode);
        ia(k:k+length(undefsa)-1) = undefsa;
        k = length(ib) + (isempty(ib) || bcodes(ib(end)) ~= tmpCode);
        ib(k:k+length(undefsb)-1) = undefsb;
    end
end

c = a; % preserve subclass
c.codes = ccodes;
c.categoryNames = cnames;
