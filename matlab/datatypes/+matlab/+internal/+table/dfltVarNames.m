function names = dfltVarNames(varIndices,oneName)
%DFLTVARNAMES Default variable names for a table.

%   Copyright 2012 The MathWorks, Inc.

prefix = getString(message('MATLAB:table:uistrings:DfltVarNamePrefix'));
if nargin < 2 || ~oneName % return cellstr
    names = matlab.internal.table.numberedNames(prefix,varIndices,false); % row vector
else % return one string
    names = matlab.internal.table.numberedNames(prefix,varIndices,true);
end
