function t = strjust(s,justify)
%STRJUST Justify cell array of strings.
%   Implementation of STRJUST for cell arrays of strings. 

%   Copyright 1984-2005 The MathWorks, Inc.

if (~iscellstr(s))
    error(message('MATLAB:strjust:NotCellstr'));
end
if nargin<2
    justify = 'right'; 
end
t = cell(size(s));
num = numel(s);
for i = 1:num
    t{i} = strjust(s{i}, justify);
end


