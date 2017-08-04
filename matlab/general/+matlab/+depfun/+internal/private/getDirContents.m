function fileNames = getDirContents(fullPath)
%getDirContents Get files with MATLAB executable extensions
%    fileNames = getDirContents(fullPath) returns a cell array
%    of the file names with .m, .p and platform-appropriate MEX
%    extensions (as determined by the MEXEXT function).  The innput   
%    must be a string representing a valid directory.  The function
%    will return an empty cell array if no files in the directory
%    have .m, .p or platform-appropriate MEX extensions. 
%
% Only return those P-files for which there is no corresponding M-file.

    dirContents_m = getDirFiles([fullPath filesep '*.m']);
    dirContents_p = getDirFiles([fullPath filesep '*.p']);
    dirContents_mex = getDirFiles([fullPath filesep '*.' mexext]);
    dirContents_mlx = getDirFiles([fullPath filesep '*.mlx']);
    fileNames = [ dirContents_m; ...
                  dirContents_p; ...
                  dirContents_mex; ...
                  dirContents_mlx ];
end

function files = getDirFiles(pth)
    dirContents = dir(pth);
    if isempty(dirContents)
        files = {};
    else
        files = {dirContents.name}';
    end
end