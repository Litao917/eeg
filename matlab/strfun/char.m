%CHAR Create character array (string).
%   S = CHAR(X) converts array X of nonnegative integer codes into a
%   character array. Valid codes range from 0 to 65535, where codes 0 to
%   127 correspond to 7-bit ASCII characters. The characters that MATLAB
%   can process (other than 7-bit ASCII characters) depend on your current
%   locale setting. Use DOUBLE to convert characters to numeric codes.
%
%   S = CHAR(C), when C is a cell array of strings, places each 
%   element of C into the rows of the character array S.  Use CELLSTR to
%   convert back.
%
%   S = CHAR(T1,T2,T3,..) forms the character array S containing the text
%   strings T1,T2,T3,... as rows.  Automatically pads each string with
%   blanks in order to form a valid matrix.  Each text parameter, Ti,
%   can itself be a character array.  This allows the creation of
%   arbitrarily large character arrays.  Empty strings are significant.
%
%   See also STRINGS, DOUBLE, CELLSTR, ISCELLSTR, ISCHAR.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.
