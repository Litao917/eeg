function tf = isfunction(files)
% ISFUNCTION Is the file a MATLAB function file?
    tf = false(1,numel(files));
    for k=1:numel(files)
        pth = files{k};
        % Can't be a function if it isn't an M-file.
        if ~isempty(pth) && isMcode(pth) && exist(pth, 'file') == 2 
            mt = matlab.depfun.internal.cacheMtree(pth);
            fcn = mtfind(mt, 'Kind', 'FUNCTION');
            tf(k) = ~isempty(fcn);
        end
    end

