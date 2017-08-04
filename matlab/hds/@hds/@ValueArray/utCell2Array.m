function [A,SampleSize] = utCell2Array(this,C)
% Converts cell array into array of uniformly-sized samples. 
% This operation succeeds only if all cell entries have the 
% same size.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
if isempty(C)
   A = [];  return
end
GridSize = size(C);
SampleSize = size(C{1});
Ne = prod(SampleSize);
Ns = prod(GridSize);
for ct=1:Ns
   if ~isequal(size(C{ct}),SampleSize)
      error('Sample size is not uniform.')
   elseif this.GridFirst
      C{ct} = hdsReshapeArray(C{ct},[1 Ne]);
   else
      C{ct} = hdsReshapeArray(C{ct},[Ne 1]);
   end
end

if this.GridFirst
   A = hdsCatArray(1,C{:});
   A = hdsReshapeArray(A,[GridSize SampleSize]);
else
   A = hdsCatArray(2,C{:});
   A = hdsReshapeArray(A,[SampleSize GridSize]);
end
