%DIR List directory.
%   DIR directory_name lists the files in a directory. Pathnames and
%   wildcards may be used.  For example, DIR *.m lists all program files
%   in the current directory.
%
%   D = DIR('directory_name') returns the results in an M-by-1
%   structure with the fields: 
%       name    -- Filename
%       date    -- Modification date
%       bytes   -- Number of bytes allocated to the file
%       isdir   -- 1 if name is a directory and 0 if not
%       datenum -- Modification date as a MATLAB serial date number.
%                  This value is locale-dependent.
%
%   See also WHAT, CD, TYPE, DELETE, LS, RMDIR, MKDIR, DATENUM.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.
