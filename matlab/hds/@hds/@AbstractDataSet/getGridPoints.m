function v = getGridPoint(this,var)
%GETGRIDPOINTS  Retrieves grid variable values.
%
%   GV = GETGRIDPOINTS(THIS,GRIDVAR) returns the vector of
%   values taken by the grid variable GRIDVAR along the
%   corresponding grid dimension.

%   Copyright 1986-2004 The MathWorks, Inc.
[var,idx] = findvar(this,var);
if isempty(idx)
   error('Only applicable to root-level grid variables.')
elseif isempty(locateGridVar(this,var))
   error('Variable %s does not belong to the grid.',var.Name)
end
v = getArray(this.Data_(idx));
