%SUM Sum of elements.
%   S = SUM(X) is the sum of the elements of the vector X. If
%   X is a matrix, S is a row vector with the sum over each
%   column. For N-D arrays, SUM(X) operates along the first
%   non-singleton dimension.
%   If X is floating point, that is double or single, S is
%   accumulated natively, that is in the same class as X,
%   and S has the same class as X. If X is not floating point,
%   S is accumulated in double and S has class double.
%
%   S = SUM(X,DIM) sums along the dimension DIM. 
%
%   S = SUM(X,'double') and S = SUM(X,DIM,'double') accumulate
%   S in double and S has class double, even if X is single.
%
%   S = SUM(X,'native') and S = SUM(X,DIM,'native') accumulate
%   S natively and S has the same class as X.
%
%   S = SUM(X,'default') and S = SUM(X,DIM,'default') are
%   equivalent to S = SUM(X) and S = SUM(X,DIM) respectively.
%
%   Examples:
%   If   X = [0 1 2
%             3 4 5]
%
%   then sum(X,1) is [3 5 7] and sum(X,2) is [ 3
%                                             12];
%
%   If X = int8(1:20) then sum(X) accumulates in double and the
%   result is double(210) while sum(X,'native') accumulates in
%   int8, but overflows and saturates to int8(127).
%
%   See also PROD, CUMSUM, DIFF, ACCUMARRAY, ISFLOAT.

%   Copyright 1984-2013 The MathWorks, Inc.

%   Built-in function.

