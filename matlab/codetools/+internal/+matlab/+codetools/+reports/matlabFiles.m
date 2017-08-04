function fileList = matlabFiles( dirname, reportName )
%MATLABFILES parses a directory and returns an array of the
% MATLAB code files that exist in that directory.
%
% This function follows the same rules as the MATLAB path and excludes
% files that begin with "._".  This function also excludes Contents.m
% from the list.
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

% Copyright 2012-2013 The MathWorks, Inc.

%% input params
if nargin < 1
    fileList = [];
end

if isdir(dirname)
    dirFileList = what(dirname);
    fileList = dirFileList.m;
    
    if (com.mathworks.services.mlx.MlxFileUtils.isMlxEnabled)
        fileList = [fileList;dirFileList.mlx];
    end
    
    % Exclude the Contents file from the list
    fileList = fileList(~strcmp(fileList,'Contents.m'));
else
    internal.matlab.codetools.reports.webError(getString(message('MATLAB:codetools:reports:IsNotAFolder', dirname)), reportName);
    return
end
end
