function m=str2rng(~) %#ok<STOUT>
%STR2RNG Convert spreadsheet range string to numeric array.
%   M = STR2RNG(RNG) converts a range in spreadsheet notation into a
%   numeric range M = [R1 C1 R2 C2].  
%
%   Example
%      str2rng('A2..AZ10') returns the vector [1 0 9 51]
%
%   STR2RNG has been removed. 
%
%   See also XLSWRITE, XLSREAD, WK1WRITE, WK1READ.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2009 The MathWorks, Inc.

error(message('MATLAB:str2rng:FunctionToBeRemoved')); 
