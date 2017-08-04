function [b,varargout] = sortrows(a,col)
%SORTROWS Sort rows of a categorical array.
%   B = SORTROWS(A) sorts the rows of the 2-dimensional categorical matrix A in
%   ascending order as a group.  B is a categorical array with the same
%   categories as A.
%
%   B = SORTROWS(A,COL) sorts A based on the columns specified in the vector
%   COL.  If an element of COL is positive, the corresponding column in A will
%   be sorted in ascending order; if an element of COL is negative, the
%   corresponding column in A will be sorted in descending order. For example,
%   SORTROWS(A,[2 -3]) sorts the rows of A first in ascending order for the
%   second column, and then by descending order for the third column.
%
%   [B,I] = SORTROWS(A) and [B,I] = SORTROWS(A,COL) also returns an index 
%   matrix I such that B = A(I,:).
%
%   Undefined elements are sorted to the end.
%
%   See also ISSORTED, SORT.

%   Copyright 2006-2013 The MathWorks, Inc. 

if nargin > 1 && ~isnumeric(col)
    error(message('MATLAB:categorical:sortrows:InvalidCol'));
end

acodes = a.codes;
% (Temporarily) give undefined elements a code greater than any legal
% code so they will sort to the end.
tmpCode = categorical.invalidCode; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        [bcodes,varargout{1:nargout-1}] = sortrows(acodes);
    else
        [bcodes,varargout{1:nargout-1}] = sortrows(acodes,col);
    end
catch ME
    throw(ME);
end
bcodes(bcodes==tmpCode) = 0;
b = a; % preserve subclass
b.codes = bcodes;
