function A = bandred(A, kl, ku)
%BANDRED  Band reduction by two-sided unitary transformations.
%   B = BANDRED(A, KL, KU) is a matrix unitarily equivalent to A
%   with lower bandwidth KL and upper bandwidth KU
%   (i.e. B(i,j) = 0 if i > j+KL or j > i+KU).
%   The reduction is performed using Householder transformations.
%   If KU is omitted it defaults to KL.

%   Called by RANDSVD.
%   This is a `standard' reduction.  Cf. reduction to bidiagonal form
%   prior to computing the SVD.  This code is a little wasteful in that
%   it computes certain elements which are immediately set to zero!
%
%   Reference:
%   G. H. Golub and C. F. Van Loan, Matrix Computations, third
%   edition, Johns Hopkins University Press, Baltimore, Maryland,
%   1996, Sec. 5.4.3.
%
%   Nicholas J. Higham
%   Copyright 1984-2013 The MathWorks, Inc.

if nargin == 2
    ku = kl;
end

% Check for special case where order of left/right transformations matters.
% Easiest approach is to work on the transpose, flipping back at the end.
flip = 0;
if ku == 0
    A = A';
    temp = kl; kl = ku; ku = temp; flip = 1;
end

[m, n] = size(A);
niter = min( min(m,n), max(m-kl-1,n-ku-1) );

for j = 1:niter
    
    if j+kl+1 <= m
        [v, beta] = house(A(j+kl:m,j),[]);
        temp = A(j+kl:m,j:n);
        A(j+kl:m,j:n) = temp - beta*v*(v'*temp);
        A(j+kl+1:m,j) = 0;
    end
    
    if j+ku+1 <= n
        [v, beta] = house(A(j,j+ku:n)',[]);
        temp = A(j:m,j+ku:n);
        A(j:m,j+ku:n) = temp - beta*(temp*v)*v';
        A(j,j+ku+1:n) = 0;
    end
    
end

if flip
    A = A';
end
