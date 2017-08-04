function A = cycol(n, k, classname)
%CYCOL  Matrix whose columns repeat cyclically.
%   A = GALLERY('CYCOL',[M N], K) is an M-by-N matrix of the form
%   A = B(1:M,1:N) where B = [C C C...] and C = RANDN(M, K).
%   Thus A's columns repeat cyclically, and A has rank at most K.
%   K need not divide N.  K defaults to ROUND(N/4).
%   GALLERY('CYCOL',N,K), where N is a scalar, is the same as
%   GALLERY('CYCOL',[N N],K).

%   Note:
%   This type of matrix can lead to underflow problems for Gaussian
%   elimination. See the reference below.
%
%   Reference:
%   NA Digest Volume 89, Issue 3 (January 22, 1989).
%
%   Copyright 1984-2013 The MathWorks, Inc.

m = n(1);              % Parameter n specifies dimension: m-by-n.
n = n(end);

if isempty(k), k = max(round(n/4),1); end

A = repmat(randn(m, k, classname),1,ceil(n/k));
A = A(:,1:n);
