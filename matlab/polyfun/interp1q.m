function yi=interp1q(x,y,xi)
%INTERP1Q Quick 1-D linear interpolation.
%
%   INTERP1Q will be removed in a future release.
%   Use INTERP1 instead. 
%
%   F=INTERP1Q(X,Y,XI) returns the value of the 1-D function Y at the points
%   of column vector XI using linear interpolation. Length(F)=length(XI).
%   The vector X specifies the coordinates of the underlying interval.
%   
%   If Y is a matrix, then the interpolation is performed for each column
%   of Y in which case F is length(XI)-by-size(Y,2).
%
%   NaN's are returned for values of XI outside the coordinates in X.
%
%   INTERP1Q is quicker than INTERP1 on non-uniformly spaced data because
%   it does no input checking. For INTERP1Q to work properly:
%   X must be a monotonically increasing column vector.
%   Y must be a column vector or matrix with length(X) rows.
%
%   Class support for inputs x, y, xi:
%      float: double, single
%
%   See also INTERP1.

%   Copyright 1984-2012 The MathWorks, Inc.

siz = size(xi);
if ~isscalar(xi)
   [xxi, k] = sort(xi);
   [~, j] = sort([x;xxi]);
   r(j) = 1:length(j);
   r = r(length(x)+1:end) - (1:length(xxi));
   r(k) = r;
   r(xi==x(end)) = length(x)-1;
   ind = find((r>0) & (r<length(x)));
   ind = ind(:);
   yi = NaN(length(xxi),size(y,2),superiorfloat(x,y,xi));
   rind = r(ind);
   xrind = x(rind);
   yrind = y(rind,:);
   yrindp1 = y(rind+1,:);
   u = (xi(ind)-xrind)./(x(rind+1)-xrind);
   onemu = 1-u;
   yra = bsxfun(@times,yrind,onemu);   
   yrp1b =  bsxfun(@times,yrindp1,u); 
   yra = yra + yrp1b;
   idx = (yrind == yrindp1); 
   yra(idx) = yrind(idx);
   yi(ind,:)= yra;
else
   % Special scalar xi case
   r = find(x <= xi,1,'last');
   r(xi==x(end)) = length(x)-1;
   if isempty(r) || r<=0 || r>=length(x)
      yi = NaN(1,size(y,2),superiorfloat(x,y,xi));
   else
      u = (xi-x(r))./(x(r+1)-x(r));
      u = u*ones(size(y(r,:)));
      idx = (y(r,:) == y(r+1,:));
      u(idx) = 1; 
      onemu = 1-u;
      yra = bsxfun(@times,y(r,:),onemu);
      yrp1b =  bsxfun(@times,y(r+1,:),u);
      yi = yra + yrp1b;
   end
end

if min(size(yi)) == 1 && numel(xi) > 1
   yi = reshape(yi,siz); 
end
