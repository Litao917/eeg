function [tf, file] = matlabFileExists(fcnPath)
% A MATLAB file may have a .p, .m, or .mlx extension. Use the WHICH and
% EXIST caches to determine if the file exists.

    function tf = fileExists(file)
        tf = ~isempty(matlab.depfun.internal.cacheWhich(file)) || ...
             matlab.depfun.internal.cacheExist(file,'file') ~= 0;
    end

    % Test in order of expected frequency: .m, .p, .mlx
    tf = false;
    
    % If the file has an extension, don't add one.
    ext = extension(fcnPath);
    if ~isempty(ext)
        tf = fileExists(fcnPath);
        file = fcnPath;
        return;
    end
    
    % This could be a loop over some extList = {'.m', '.p', '.mlx'}.
    % I've unrolled the loop in hopes of better performance. Premature
    % optimization? Used nesting to avoid repeating ext strings.
    file = [fcnPath '.m'];
    if fileExists(file)
        tf = true;
    else
        file = [fcnPath '.p'];
        if fileExists(file)
            tf = true;
        else
            file = [fcnPath '.mlx'];
            if fileExists(file)
                tf = true;
            end
        end
    end
end
