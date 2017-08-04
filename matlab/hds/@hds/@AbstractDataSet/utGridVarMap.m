function GridDim = utGridVarMap(this,Vars)
% Returns index vector commensurate with VARS indicating
% which grid dimension each variable belongs to (and 
% zero if none)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
AllVars = this.Cache_.Variables;
gDim = this.Cache_.GridDim;
[ia,ib] = utIntersect(Vars,AllVars(1:length(gDim)));
GridDim = zeros(length(Vars),1);
GridDim(ia) = gDim(ib);
