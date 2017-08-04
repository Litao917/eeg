function names = dfltRowNames(rowIndices,oneName)
%DFLTROWNAMES Default row names for a table.

%   Copyright 2012 The MathWorks, Inc.

prefix = getString(message('MATLAB:table:uistrings:DfltRowNamePrefix'));
if nargin < 2 || ~oneName % return cellstr
    names = matlab.internal.table.numberedNames(prefix,rowIndices,false)'; % column vector
else % return one string
    names = matlab.internal.table.numberedNames(prefix,rowIndices,true);
end
