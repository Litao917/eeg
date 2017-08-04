function tf = isClassdef(file)
% isClassdef Does file contain a MATLAB class defintion?
    tf = false;
    % Make sure this is a MATLAB function (file name must end with .m 
    % or .mlx). If it's a .p file, look for the .m file instead.
    ext = extension(file);
    if strcmp(ext, '.p')
        file(end-1:end) = '.m';
        ext = '.m';
    end

    if strcmp(ext, '.m') || strcmp(ext, '.mlx')
        tf = hasClassDef(file);
    elseif isempty(extension(file))
        % .mlx has higher precedence than .m.
        tf = hasClassDef([file '.mlx']);
        if ~tf
            tf = hasClassDef([file '.m']);
        end
    end
end

function tf = hasClassDef(file)
    tf = false;
    % If the MATLAB file exists, does it contain CLASSDEF?
    % cacheMtree checks the file existence.
    mt = matlab.depfun.internal.cacheMtree(file);
    if ~isempty(mt)
        tf = ~isempty(mtfind(mt,'Kind','CLASSDEF'));
    end
end
