%MISLOCKED True if M-file or MEX-file cannot be cleared.
%   MISLOCKED(FUN) returns logical 1 (TRUE) if the function named FUN 
%   is locked in memory and logical 0 (FALSE) otherwise.  Locked M-files 
%   or MEX-files cannot be CLEARED.
%
%   MISLOCKED, by itself, returns logical 1 (TRUE) if the currently 
%   running M-file or MEX-file is locked and logical 0 (FALSE) otherwise.
%
%   See also MLOCK, MUNLOCK.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
