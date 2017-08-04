function [c,ia,ib] = union(a,b,varargin)
%UNION Set union for categorical arrays.
%   C = UNION(A,B) for categorical arrays A and B, returns the combined values
%   of the two arrays with no repetitions.  Either A or B may also be a cell
%   array of strings.  C is sorted.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names. In this case, C's categories are the sorted union of A's and
%   B's categories.
%  
%   C = UNION(A,B,'rows') for categorical matrices A and B with the same number
%   of columns, returns the combined rows from the two matrices with no
%   repetitions.  Either A or B may also be a cell array of strings.  The rows
%   of the matrix C are in sorted order.
% 
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such
%   that C is a sorted combination of the values A(IA) and B(IB).
%   If there are common values in A and B, then the index is returned in IB.
%   If there are repeated values in A or B, then the index of the last
%   occurrence of each repeated value is returned.  
%  
%   [C,IA,IB] = UNION(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of the rows A(IA,:) and B(IB,:).
% 
%   [C,IA,IB] = UNION(A,B,'stable') for categorical arrays A and B, returns
%   the values of C in the same order that they appear in A, then B.
%   [C,IA,IB] = UNION(A,B,'sorted') returns the values of C in sorted order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are common values in A and B, then the index is returned in
%   IA. If there are repeated values in A or B, then the index of the
%   first occurrence of each repeated value is returned.
% 
%   [C,IA,IB] = UNION(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A, then B.
%   [C,IA,IB] = UNION(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
% 
%   UNION(A,B,'legacy') and UNION(A,B,'rows','legacy') preserve the behavior of
%   the UNION function from R2012b and prior releases.
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2006-2013 The MathWorks, Inc. 

import matlab.internal.tableUtils.isStrings

narginchk(2,Inf);

if ~isa(a,'categorical') || ~isa(b,'categorical')
    % Accept [] as a valid "identity element" for either arg.
    if isStrings(a)
        a = strings2categorical(a,b);
    elseif isequal(a,[])
        a = b; a.codes = cast([],categorical.codesClass);
    elseif isStrings(b)
        b = strings2categorical(b,a);
    elseif isequal(b,[])
        b = a; b.codes = cast([],categorical.codesClass);
    else
        error(message('MATLAB:categorical:setmembership:TypeMismatch','UNION'));
    end
elseif a.isOrdinal ~= b.isOrdinal
    error(message('MATLAB:categorical:setmembership:OrdinalMismatch','UNION'));
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

% Set the integer value for undefined elements to the largest integer.  union
% will put one of these at the end, if any are present in A or B.
tmpCode = categorical.invalidCode; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,ia,ib] = union(acodes,bcodes,varargin{:});
    else
        ccodes = union(acodes,bcodes,varargin{:});
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa) || ~isempty(undefsb)
    % There will always already be a single tmpCode at the end of ccodes
    ccodes(end:end+length(undefsa)+length(undefsb)-1) = 0;
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
