function tf = isString(x)
%ISSTRING  True for a character string.
%   ISSTRING(S) returns true if S is a row character array and false
%   otherwise.
%
%   See also ISCELLSTRING.

%   Copyright 2012 The MathWorks, Inc.

tf = ischar(x) && ( isrow(x) || isequal(x, '') );

end
