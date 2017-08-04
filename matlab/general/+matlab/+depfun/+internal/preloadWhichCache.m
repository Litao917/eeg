function preloadWhichCache(database, pth)
% Preload the WHICH cache from the given database.
% 
%  DATABASE: Full path to the database file. DependencyDepot will create
%  the database if necessary.
%
%  PTH: A cell-array of path items; order matters, as this list controls
%  the precedence of builtins with the same name and the availability of
%  builtins with assigned toolbox locations.

    % There's nothing to do if the database doesn't exist.
    if exist(database,'file') ~= 2
        return;
    end
    
    % Connect to the database
    dd = matlab.depfun.internal.DependencyDepot(database);
    dbClose = onCleanup(@()dd.disconnect);

    % Empty the cache
    matlab.depfun.internal.cacheWhich();
    
    % Load all the builtins from the database, normalizing their
    % paths to the MATLAB root.
    tbl = dd.getBuiltinTable(pth);
    
    % Wrap the values in 'built-in ( ... )' so the cache will return the same
    % string returned by MATLAB.
    function whichResult = wrapPath(sym,type,loc)
        builtinStr = 'built-in';
        whichResult = sprintf('%s (undocumented)', builtinStr);
        switch(type)
            case matlab.depfun.internal.MatlabType.BuiltinClass
                whichResult = ...
                    sprintf('%s is a %s method %% %s constructor', ...
                        sym, builtinStr, sym);
            case matlab.depfun.internal.MatlabType.BuiltinMethod
                whichResult = ...
                    sprintf('%s is a %s method', sym, builtinStr);
            case matlab.depfun.internal.MatlabType.BuiltinFunction
               if ~isempty(loc)
                    whichResult = [builtinStr ' (' loc filesep sym ')'];
               end
        end 
    end

    v = tbl.values;
    values = [v{:}]; % MATLAB! Why can't I concatentate indexing operations?
    if ~isempty(values)
        type = { values.type };
        loc = { values.loc };
        builtinStr = cellfun(@(sym,type,loc)wrapPath(sym,type,loc), ...
                             tbl.keys, type, loc, ...
                             'UniformOutput', false); 

        % Preload the cache
        matlab.depfun.internal.cacheWhich(tbl.keys, builtinStr);    
    end
end
