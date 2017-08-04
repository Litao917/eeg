%PROD Product of elements.
%   S = PROD(X) is the product of the elements of the vector X. If
%   X is a matrix, S is a row vector with the product over each
%   column. For N-D arrays, PROD(X) operates on the first
%   non-singleton dimension.
%   If X is floating point, that is double or single, S is
%   computed natively, that is in the same class as X,
%   and S has the same class X. If X is not floating point,
%   S is computed in double and S has class double.
%
%   PROD(X,DIM) works along the dimension DIM. 
%
%   S = PROD(X,'double') and S = PROD(X,DIM,'double') compute
%   S in double and S has class double, even if X is single.
%
%   S = PROD(X,'native') and S = PROD(X,DIM,'native') compute 
%   S natively and S has the same class as X.
%
%   S = PROD(X,'default') and S = PROD(X,DIM,'default') are
%   equivalent to S = PROD(X) and S = PROD(X,DIM) respectively.
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then prod(X,1) is [0 4 10] and prod(X,2) is [ 0
%                                                60]
%
%   See also SUM, CUMPROD, DIFF.

%   Copyright 1984-2013 The MathWorks, Inc.

%   Built-in function.

