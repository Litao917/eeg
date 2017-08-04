function A = utGridFill(this,A,GridSize,GridDim)
%UTGRIDFILL  Turns value set for grid dimension into full array.
%
%   A = UTGRIDFILL(A,GRIDSIZE,GRIDDIM) takes the array
%   of grid point values along the grid dimension GRIDDIM 
%   and expands it into an array covering the entire grid.

%   Copyright 1986-2004 The MathWorks, Inc.
if any(GridSize>1) && ~isempty(A)
   % Form full array
   s1 = ones(size(GridSize));
   s1(GridDim) = GridSize(GridDim);
   s2 = GridSize;
   s2(GridDim) = 1;
   A = hdsReplicateArray(hdsReshapeArray(A,s1),s2);
end