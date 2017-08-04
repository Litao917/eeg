function A = chow(n, alpha, delta, classname)
%CHOW Chow matrix (singular Toeplitz lower Hessenberg matrix).
%   A = GALLERY('CHOW',N,ALPHA,DELTA) returns A such that
%      A = H(ALPHA) + DELTA*EYE, where H(i,j) = ALPHA^(i-j+1).
%   H(ALPHA) has p = FLOOR(N/2) zero eigenvalues, the rest being
%   4*ALPHA*COS( k*PI/(N+2) )^2, k=1:N-p.
%   Defaults: ALPHA = 1, DELTA = 0.

%   References:
%   [1] T. S. Chow, A class of Hessenberg matrices with known eigenvalues
%       and inverses, SIAM Review, 11 (1969), pp. 391-395.
%   [2] G. Fairweather, On the eigenvalues and eigenvectors of a class of
%       Hessenberg matrices, SIAM Review, 13 (1971), pp. 220-221.
%   [3] I. Singh, G. Poole and T. Boullion, A class of Hessenberg matrices
%       with known pseudoinverse and Drazin inverse, Math. Comp., 29 (1975),
%       pp. 615-619.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(alpha), alpha = ones(classname); end
if isempty(delta), delta = zeros(classname); end

A = toeplitz( alpha.^(1:n), [alpha 1 zeros(1,n-2,classname)] ) + ...
              delta*eye(n,classname);
