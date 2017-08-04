function [c,varargout] = min(a,b,dim)
%MIN Smallest element in an ordinal categorical array.
%   B = MIN(A), when A is an ordinal categorical vector, returns the smallest
%   element in A. For matrices, MIN(A) is a row vector containing the minimum
%   element from each column.  For N-D arrays, MIN(A) operates along the first
%   non-singleton dimension.  B is an ordinal categorical array with the same
%   categories as A.
%
%   [B,I] = MIN(A) returns the indices of the minimum values in vector I. If
%   the values along the first non-singleton dimension contain more than one
%   minimal element, the index of the first one is returned.
%
%   C = MIN(A,B) returns an ordinal categorical array the same size as A and B
%   with the smallest elements taken from A or B.  A and B must have the same
%   sets of categories, including their order.  Either A or B may also be a cell
%   array of strings.
%
%   [B,I] = MIN(A,[],DIM) operates along the dimension DIM. 
%
%   Undefined elements are ignored when computing the minimum.  When all
%   elements in A are undefined, then MIN returns an index to the first one in
%   I.  When corresponding elements of A and B are both undefined, MIN returns
%   an undefined element in C.
%
%   See also MIN, SORT.

%   Copyright 2006-2013 The MathWorks, Inc.

if nargin > 2 && ~isnumeric(dim)
    error(message('MATLAB:categorical:min:InvalidDim'));
end

if (nargin < 2) || isequal(b,[]) % && isa(a,'categorical')
    if ~a.isOrdinal
        error(message('MATLAB:categorical:NotOrdinal'));
    end
    
    acodes = a.codes;
    bcodes = [];
    c = a; % preserve subclass
else
    % Accept +Inf as a valid "identity element" in the two-arg case.  If compared
    % to <undefined>, the maximal value will be the result.
    if isequal(a,Inf) % && isa(b,'categorical')
        acodes = cast(length(b.categoryNames),categorical.codesClass); % maximal value, or <undefined>
        bcodes = b.codes;
    elseif isequal(b,Inf) % && isa(a,'categorical')
        acodes = a.codes;
        bcodes = cast(length(a.categoryNames),categorical.codesClass); % maximal value, or <undefined>
    else
        [acodes,bcodes] = reconcileCategories(a,b,true);
    end
    if isa(a,'categorical')
        c = a; % preserve subclass
    else
        c = b; % preserve subclass
    end
end

% Set the code value for undefined elements to the largest integer to make
% sure they will not be the min value unless there's nothing else.
tmpCode = categorical.invalidCode; % not a legal code
acodes(acodes==0) = tmpCode;
bcodes(bcodes==0) = tmpCode;
try
    if nargin == 1
        [ccodes,varargout{1:nargout-1}] = min(acodes);
    elseif nargin == 2
        [ccodes,varargout{1:nargout-1}] = min(acodes,bcodes);
    else
        [ccodes,varargout{1:nargout-1}] = min(acodes,bcodes,dim);
    end
catch ME
    throw(ME);
end
ccodes(ccodes==tmpCode) = 0; % restore undefined code
c.codes = ccodes;
