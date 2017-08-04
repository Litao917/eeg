function matlabCodeAsCellArray = getmcode(filename)
%GETMCODE  Returns a cell array of the text in a MATLAB code file
%   matlabCodeAsCellArray = getmcode(filename)

% Copyright 1984-2013 The MathWorks, Inc.

fileContentsAsString = matlab.internal.getCode(filename);
if (isempty(fileContentsAsString))
    matlabCodeAsCellArray ={};
else
    fileContentsAsCellArray = textscan(fileContentsAsString,'%s','delimiter','\n','whitespace','');
    % "textscan" returns a cell array of cell arrays.  
    % Each cell inside the first cell corresponds to one line in the file
    matlabCodeAsCellArray = fileContentsAsCellArray{1}; 
end
end
