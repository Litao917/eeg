function cdirs = catdirs(varargin)
%CATDIRS Concatenate separate strings of directories into one string. 
%   CATDIRS DIRNAME checks that DIRNAME is a string, removes any leading
%   or tailing whitespace, and appends a path separator.
%
%   CATDIRS  DIR1 DIR2 DIR3 ... for each input, checks it is a string, removes 
%    any leading or tailing whitespace, and appends a path separator; and then 
%    concatenates all these strings.
%
%   Example:
%       dirlist = catdirs('/home/user/matlab','/home/user/matlab/test');

%   Copyright 1984-2011 The MathWorks, Inc.

n= nargin;
narginchk(1,Inf);

cdirs = '';

for i=1:n
    next = varargin{i};
    if ~ischar(next)
        error(message('MATLAB:catdirs:ArgNotString'));
    end
    % Remove leading and trailing whitespace
	next = strtrim(next);
    if ~isempty(next)
        cdirs = [cdirs next pathsep]; %#ok<AGROW>
    end
end
