function width = getStringDisplayWidth(str)
% This function is undocumented.

%  Copyright 2012 MathWorks, Inc.

width = length(str) + nnz(double(str) > 256);
end
