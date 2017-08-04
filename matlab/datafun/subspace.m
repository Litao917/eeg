function theta = subspace(A,B)
%SUBSPACE Angle between subspaces.
%   SUBSPACE(A,B) finds the angle between two subspaces specified by the
%   columns of A and B.
%
%   If the angle is small, the two spaces are nearly linearly dependent.
%   In a physical experiment described by some observations A, and a second
%   realization of the experiment described by B, SUBSPACE(A,B) gives a
%   measure of the amount of new information afforded by the second
%   experiment not associated with statistical errors of fluctuations.
%
%   Class support for inputs A, B:
%      float: double, single

%   The algorithm used here ensures that small angles are computed
%   accurately, and it allows subspaces of different dimensions following
%   the definition in [2]. The first issue is crucial.  The second issue is
%   not so important; but since the definition from [2] coinsides with the
%   standard definition when the dimensions are equal, there should be no
%   confusion - and subspaces with different dimensions may arise in
%   problems where the dimension is computed as the numerical rank of some
%   inaccurate matrix.

%   References:
%   [1] A. Bjorck & G. Golub, Numerical methods for computing
%       angles between linear subspaces, Math. Comp. 27 (1973),
%       pp. 579-594.
%   [2] P.-A. Wedin, On angles between subspaces of a finite
%       dimensional inner product space, in B. Kagstrom & A. Ruhe (Eds.),
%       Matrix Pencils, Lecture Notes in Mathematics 973, Springer, 1983,
%       pp. 263-285.

%   Thanks to Per Christian Hansen
%   Copyright 1984-2011 The MathWorks, Inc. 

% Compute orthonormal bases, using SVD in "orth" to avoid problems
% when A and/or B is nearly rank deficient.
A = orth(A);
B = orth(B);
%Check rank and swap
if size(A,2) < size(B,2)
   [A,B] = swap(A,B); 
end
% Compute the projection according to [1].
B = B - A*(A'*B);
% Make sure it's magnitude is less than 1.
theta = asin(min(ones(superiorfloat(A,B)),norm(B)));
end

function [B, A] = swap(A, B)
end

