function t = isvarname(s)
%ISVARNAME True for valid variable name.
%   ISVARNAME(S) is true if S is a valid MATLAB variable name.
%   A valid variable name is a character string of letters, digits and
%   underscores, with length <= namelengthmax, the first character a letter,
%   and the name is not a keyword.
%
%   See also MATLAB.LANG.MAKEVALIDNAME, ISKEYWORD, NAMELENGTHMAX.

%   Copyright 1984-2013 The MathWorks, Inc.

