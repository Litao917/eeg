function T = toeppd(n, m, w, theta, classname)
%TOEPPD Symmetric positive definite Toeplitz matrix.
%   GALLERY('TOEPPD',N,M,W,THETA) is an N-by-N symmetric positive
%   semi-definite (SPD) Toeplitz matrix. It is composed of the sum of
%   M rank 2 (or, for certain THETA rank 1) SPD Toeplitz matrices.
%   Specifically,
%      T = W(1)*T(THETA(1)) + ... + W(M)*T(THETA(M)),
%   where T(THETA(k)) has (i,j) element COS(2*PI*THETA(k)*(i-j)).
%
%   Defaults: M = N, W = RAND(M,1), THETA = RAND(M,1).

%   Reference:
%   G. Cybenko and C. F. Van Loan, Computing the minimum eigenvalue of
%   a symmetric positive definite Toeplitz matrix, SIAM J. Sci. Stat.
%   Comput., 7 (1986), pp. 123-131.
%
%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(m), m = n; end
if isempty(w), w = rand(m,1); end
if isempty(theta), theta = rand(m,1); end

if length(w) ~= m || length(theta) ~= m
   error(message('MATLAB:toeppd:InvalidLengthWAndTheta'))
end

T = zeros(n,classname);
e = 1:cast(n,classname);
E = 2*pi*bsxfun(@minus, e', e);

for i=1:m
    T = T + w(i) * cos( theta(i)*E );
end
