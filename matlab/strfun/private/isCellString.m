function tf = isCellString(x)
%ISCELLSTRING  True for a cell array of strings.
%   ISSTRING(C) returns true if C is a cell array containing only row
%   character arrays and false otherwise.
%
%   See also ISSTRING.

%   Copyright 2012 The MathWorks, Inc.

tf = iscell(x) && ( isrow(x) || isequal(x, {}) ) && ...
     all(cellfun(@isString, x));

end
