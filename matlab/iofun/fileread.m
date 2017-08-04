function out=fileread(filename)
%FILEREAD Return contents of file as string vector.
%   TEXT = FILEREAD('FILENAME') returns the contents of the file FILENAME as a
%   MATLAB string.
%
%   See also FREAD, TEXTSCAN, LOAD, WEB.

% Copyright 1984-2011 The MathWorks, Inc.

% Validate input args
narginchk(1, 1);

% get filename
if ~ischar(filename), 
    error(message('MATLAB:fileread:filenameNotString')); 
end

% do some validation
if isempty(filename), 
    error(message('MATLAB:fileread:emptyFilename')); 
end

% open the file
[fid, msg] = fopen(filename);
if fid == (-1)
    error(message('MATLAB:fileread:cannotOpenFile', filename, msg));
end

try
    % read file
    out = fread(fid,'*char')';
catch exception
    % close file
    fclose(fid);
	throw(exception);
end

% close file
fclose(fid);
