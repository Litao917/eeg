function U = kahan(n, theta, pert, classname)
%KAHAN Kahan matrix.
%   B = GALLERY('KAHAN', N, THETA, PERT) is an upper trapezoidal
%   matrix that has interesting properties regarding estimation of
%   condition and rank. If N is a two-element vector, then B is
%   N(1)-by-N(2); otherwise, B is is N-by-N. The useful range of
%   THETA is 0 < THETA < PI. THETA defaults to 1.2.
%
%   To ensure that the QR factorization with column pivoting does not
%   interchange columns in the presence of rounding errors, the
%   diagonal is perturbed by PERT*EPS*DIAG( [N:-1:1] ). The default
%   PERT is 1E3, which ensures no interchanges for GALLERY('KAHAN',N)
%   up to at least N = 100 in IEEE double precision arithmetic.

%   Notes:
%   The inverse of KAHAN(N, THETA) is known explicitly ([2], p. 161).
%   The diagonal perturbation was suggested by Christian Bischof.
%
%   References:
%   [1] W. Kahan, Numerical linear algebra, Canadian Math. Bulletin,
%       9 (1966), pp. 757-801.
%   [2] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, 2002, Sec. 8.3.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(pert), pert = cast(1e3,classname); end
if isempty(theta), theta = cast(1.2,classname); end

r = n(1);              % Parameter n specifies dimension: r-by-n.
n = n(length(n));

s = sin(theta);
c = cos(theta);

U = eye(n,classname) - c*triu(ones(n,classname), 1);
U = diag(s.^(0:n-1))*U + pert*eps(classname)*diag( (n:-1:1) );
if r > n
   U(r,n) = 0;         % Extend to an r-by-n matrix.
else
   U = U(1:r,:);       % Reduce to an r-by-n matrix.
end
