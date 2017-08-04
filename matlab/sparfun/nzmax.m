%NZMAX  Amount of storage allocated for nonzero matrix elements.
%   For a sparse matrix, NZMAX(S) is the number of storage locations
%   allocated for the nonzero elements in S.
%
%   For a full matrix, NZMAX(S) is prod(size(S)).
%   In both cases, nnz(S) <= nzmax(S) <= prod(size(S)).
%
%   See also NNZ, NONZEROS, SPALLOC.

%   Copyright 1984-2013 The MathWorks, Inc. 
%   Built-in function.
