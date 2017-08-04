function tf = isExecutable(file)
% isExecutable Is file executable (based on extension).
% FILE is a single string or a cell array of file names. Performance really
% matters, as this function may be called thousands or millions of times.
% Therefore, the code is not as compact as it otherwise might be.
    
    if iscell(file)
        fileCount = numel(file);
        tf = false(fileCount);
        for k=1:fileCount
            ext = extension(file{k});
            tf(k) = strcmp(ext,'.m') || strcmp(ext,'.p') || strcmp(ext,'.mlx');
        end
    elseif ischar(file)
        ext = extension(file);
        tf = strcmp(ext,'.m') || strcmp(ext,'.p') || strcmp(ext,'.mlx');
    else
        tf = [];
    end
    
end
