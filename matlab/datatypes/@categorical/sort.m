function [b,varargout] = sort(a,dim,mode)
%SORT Sort a categorical array.
%   B = SORT(A), when A is a categorical vector, sorts the elements of A in
%   ascending order.  For matrices, SORT(A) sorts each column of A in ascending
%   order. For N-D arrays, SORT(A) sorts the along the first non-singleton
%   dimension of A.  B is a categorical array with the same categories as A.
%
%   B = SORT(A,DIM) sorts A along dimension DIM.
%
%   B = SORT(A,DIM,MODE) sorts A in the order specified by MODE.  MODE is
%   'ascend' for ascending order, or 'descend' for descending order.
%
%   [B,I] = SORT(A,...) also returns an index matrix I.  If A is a
%   vector, then B = A(I).  If A is an m-by-n matrix and DIM = 1, then
%   B(:,j) = A(I(:,j),j) for j = 1:n.
%
%   Undefined elements are sorted to the end.
%
%   See also ISSORTED, SORTROWS.

%   Copyright 2006-2013 The MathWorks, Inc. 

if nargin > 1 && ~isnumeric(dim)
    error(message('MATLAB:categorical:sort:InvalidDim'));
elseif nargin > 2 && ~ischar(mode)
    error(message('MATLAB:categorical:sort:InvalidMode'));
end

acodes = a.codes;

% (Temporarily) give undefined elements a code greater than any legal
% code so they will sort to the end.
tmpCode = categorical.invalidCode; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        [bcodes,varargout{1:nargout-1}] = sort(acodes);
    elseif nargin == 2
        [bcodes,varargout{1:nargout-1}] = sort(acodes,dim);
    else
        [bcodes,varargout{1:nargout-1}] = sort(acodes,dim,mode);
    end
catch ME
    throw(ME);
end
bcodes(bcodes==tmpCode) = 0; % restore undefined code
b = a;
b.codes = bcodes;
