function GridDim = locateGridVar(this,Variable)
%LOCATEGRIDVAR  Locates variable in grid.
%
%   GDIM = LOCATEGRIDVAR(D,VAR) returns the grid dimension DIM
%   to which the variable VAR belongs, and [] if VAR is not
%   part of the grid.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
GridDim = [];
for ct=1:length(this.Grid_)
   if any(Variable == this.Grid_(ct).Variable)
      GridDim = ct;
      break;
   end
end