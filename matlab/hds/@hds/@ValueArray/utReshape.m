function A = utReshape(this,A,GridSize)
% Reshapes array to specified grid size

%   Copyright 1986-2004 The MathWorks, Inc.
if ~isempty(A)
   if this.GridFirst
      A = hdsReshapeArray(A,[GridSize this.SampleSize]);
   else
      A = hdsReshapeArray(A,[this.SampleSize GridSize]);
   end
end