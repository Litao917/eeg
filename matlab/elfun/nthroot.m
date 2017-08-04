function y = nthroot(x, n)
%NTHROOT Real n-th root of real numbers.
%
%   NTHROOT(X, N) returns the real Nth root of the elements of X.
%   Both X and N must be real, and if X is negative, N must be an odd integer.
%
%   Class support for inputs X, N:
%      float: double, single
%
%   See also POWER.

%   Thanks to Peter J. Acklam (http://home.online.no/~pjacklam)
%   Copyright 1984-2010 The MathWorks, Inc.

if ~isreal(x) || ~isreal(n)
   error(message('MATLAB:nthroot:ComplexInput'));
end

if ~isscalar(x) && ~isscalar(n) && ~isequal(size(x),size(n))
   error(message('MATLAB:nthroot:NonmatchDim'));
end

xc = x; nc = n;
if isscalar(x)
    xc = repmat(x,size(n));
elseif isscalar(n)
    nc = repmat(n,size(x));
end

if any((x(:) < 0) & (n(:) ~= fix(n(:)) | rem(n(:),2)==0))
   error(message('MATLAB:nthroot:NegXNotOddIntegerN'));
end

y = nthrootssign(xc) .* (abs(xc).^(1./nc));

% Correct numerical errors (since, e.g., 64^(1/3) is not exactly 4)
% by one iteration of Newton's method
if all(isfinite(n(:)))
    m = (xc ~= 0 & abs(xc) < (1/eps(class(y)))); 
    ym = y(m); ncm = nc(m);
    y(m) = ym - (ym.^ncm - xc(m)) ./ (ncm .* ym.^(ncm-1));
end

function y = nthrootssign(x)
% return 1 if x >= 0, and -1 otherwise.
y = ones(size(x));
y(x<0) = -1;

      

