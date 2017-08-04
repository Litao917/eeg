function A = gcdmat(n,classname)
%GCDMAT  GCD matrix.
%   A = GALLERY('GCDMAT',N) is the N-by-N matrix with (i,j) entry
%   GCD(i,j).  A is symmetric positive definite, and A.^r is
%   symmetric positive semidefinite for all nonnegative r.

%   Reference:
%   R. Bhatia, Infinitely divisible matrices, Amer. Math. Monthly,
%   (2005), to appear.
%
%   Copyright 1984-2013 The MathWorks, Inc.

a = 1:cast(n,classname);
A = bsxfun(@gcd, a, a.');
