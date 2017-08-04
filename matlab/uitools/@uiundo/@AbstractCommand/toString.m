function str = toString(hThis)

% Copyright 2002 The MathWorks, Inc.

str = getString(message('MATLAB:uistring:uiundo:CommandString',hThis.Name));
