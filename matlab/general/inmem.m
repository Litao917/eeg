%INMEM List functions in memory. 
%   M = INMEM returns a cell array of strings containing the names
%   of program files that are in the P-code buffer.
%
%   M = INMEM('-completenames') is similar, but each element of
%   the cell array has the directory, file name, and file extension.
%
%   [M,MEX]=INMEM also returns a cell array containing the names of
%   the MEX files that have been loaded.
%
%   [M,MEX,C]=INMEM also returns a cell array containing the names of
%   the classes that have been loaded. 
%
%   Examples:
%      clear all % start with a clean slate
%      magic(10)
%      m = inmem
%   lists the program files that were required to run magic.
%      m1 = inmem('-completenames')
%   lists the same files, each with directory, name, and extension.
%
%   See also WHOS, WHO.

%   Copyright 1984-2012 The MathWorks, Inc.
%   Built-in function.
