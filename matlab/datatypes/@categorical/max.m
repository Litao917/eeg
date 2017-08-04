function [c,varargout] = max(a,b,dim)
%MAX Largest element in an ordinal categorical array.
%   B = MAX(A), when A is an ordinal categorical vector, returns the largest
%   element in A. For matrices, MAX(A) is a row vector containing the maximum
%   element from each column.  For N-D arrays, MAX(A) operates along the first
%   non-singleton dimension.  B is an ordinal categorical array with the same
%   categories as A.
%
%   [B,I] = MAX(A) returns the indices of the maximum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one maximal element, the index of the first one is returned.
%
%   C = MAX(A,B) returns an ordinal categorical array the same size as A and B
%   with the largest elements taken from A or B.  A and B must have the same
%   sets of categories, including their order.  Either A or B may also be a cell
%   array of strings.
%
%   [B,I] = MAX(A,[],DIM) operates along the dimension DIM. 
%
%   Undefined elements are ignored when computing the minimum.  When all
%   elements in A are undefined, then MAX returns an index to the first one in
%   I.  When corresponding elements of A and B are both undefined, MAX returns
%   an undefined element in C.
%
%   See also MIN, SORT.

%   Copyright 2006-2013 The MathWorks, Inc.

if nargin > 2 && ~isnumeric(dim)
    error(message('MATLAB:categorical:max:InvalidDim'));
end

if (nargin < 2) || isequal(b,[]) % && isa(a,'categorical')
    if ~a.isOrdinal
        error(message('MATLAB:categorical:NotOrdinal'));
    end
    
    acodes = a.codes;
    bcodes = [];
    c = a; % preserve subclass
else
    % Accept -Inf as a valid "identity element" in the two-arg case.  If compared
    % to <undefined>, the minimal value will be the result.
    if isequal(a,-Inf) % && isa(b,'categorical')
        acodes = cast(min(1,length(b.categoryNames)),categorical.codesClass); % minimal value, or <undefined>
        bcodes = b.codes;
    elseif isequal(b,-Inf) % && isa(a,'categorical')
        acodes = a.codes;
        bcodes = cast(min(1,length(a.categoryNames)),categorical.codesClass); % minimal value, or <undefined>
    else
        [acodes,bcodes] = reconcileCategories(a,b,true);
    end
    if isa(a,'categorical')
        c = a; % preserve subclass
    else
        c = b; % preserve subclass
    end
end

% Undefined elements have code zero, less than any legal code.  They will not
% be the max value unless there's nothing else.
try
    if nargin == 1
        [ccodes,varargout{1:nargout-1}] = max(acodes);
    elseif nargin == 2
        [ccodes,varargout{1:nargout-1}] = max(acodes,bcodes);
    else
        [ccodes,varargout{1:nargout-1}] = max(acodes,bcodes,dim);
    end
catch ME
    throw(ME);
end
c.codes = ccodes;
