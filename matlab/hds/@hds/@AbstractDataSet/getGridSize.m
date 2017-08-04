function s = getGridSize(this,dim)
%GETGRIDSIZE  Returns grid size or grid dimension length.

%   Copyright 1986-2004 The MathWorks, Inc.
g = this.Grid_;
if isempty(g)
   s = [0 0];
else
   s = [g.Length];
end
s = [s ones(1,2-length(s))];

if nargin>1
   if dim>length(s)
      s = 1;
   else
      s = s(dim);
   end
end