function A = vander(v)
%VANDER Vandermonde matrix.
%   A = VANDER(V) returns the Vandermonde matrix whose columns
%   are powers of the vector V, that is A(i,j) = v(i)^(n-j).
%
%   Class support for input V:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc. 

n = length(v);
v = v(:);
A = ones(n,class(v));
for j = n-1:-1:1
    A(:,j) = v.*A(:,j+1);
end
