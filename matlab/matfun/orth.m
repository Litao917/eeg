function Q = orth(A)
%ORTH   Orthogonalization.
%   Q = ORTH(A) is an orthonormal basis for the range of A.
%   That is, Q'*Q = I, the columns of Q span the same space as 
%   the columns of A, and the number of columns of Q is the 
%   rank of A.
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, RANK, NULL.

%   Copyright 1984-2011 The MathWorks, Inc. 

[Q,S] = svd(A,'econ'); %S is always square.
if ~isempty(S)
    S = diag(S);
    tol = max(size(A)) * S(1) * eps(class(A));
    r = sum(S > tol);
    Q = Q(:,1:r);
end
