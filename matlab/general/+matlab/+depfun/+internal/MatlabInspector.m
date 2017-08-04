classdef MatlabInspector < handle
% MatlabInspector Determine what files and classes a MATLAB function requires.
% Analyze the symbols used in a MATLAB function to determine which correspond
% to functions or class methods. 

% Copyright 2012 The MathWorks, Inc.

    properties
        BuiltinList
        Rules
        Target
    end
    
    properties (Access=private)
        addDep
        addClassDep
        addExclusion
        addExpected
        fsCache
        useDB
        pickUserFiles
		isWin32
        BuiltinMethodInfo
    end

    properties(Constant)
        BuiltinClasses = matlabBuiltinClasses;
        KnownExtensions = initKnownExtensions();
    end

    methods(Static)
        
        function tf = knownExtension(ext)
        % knownExtension Is the extension "owned" by MATLAB? 
            tf = isKey(matlab.depfun.internal.MatlabInspector.KnownExtensions, ext);
        end
        
        function symbol = resolveType(name, fsCache, addExc)
        % resolveType Examine a name to determine its type
        % 
        % Defer to MatlabSymbol's more perfect knowledge about symbols to
        % determine the fully qualified name of each input identifier. An
        % identifier may refer to a file on the MATLAB path or may be the
        % package-qualified name of a method or a class.
          
            if ~ischar(name)
                error(message('MATLAB:Completion:NameMustBeChar', ...
                              1, class(name)));
            end
            
            % TODO: Check for dot-qualified names here, maybe. The
            % names may be file names, though, which might have dots 
            % in them.
                       
            % Determine if we've been passed a file name rather than a 
            % function name.
            % G886754: If it is M-code, look for its corresponding 
            % MEX file first.
            fullpath = '';
            mExtIdx = regexp(name,'\.m$','ONCE');
            if ~isempty(mExtIdx)
                MEXname = [name(1:mExtIdx) mexext];
                [fullpath, symName, fileType] = resolveFileName(MEXname);
				% G968392: A DLL file can be a valid MEX file on win32.
				% If a DLL file coexists with a MEXW32 file, pick the MEXW32 file.
				if isempty(fullpath) && strcmp(computer('arch'), 'win32')
					MEXname = [name(1:mExtIdx) 'dll'];
					[fullpath, symName, fileType] = resolveFileName(MEXname);
				end
            end
            
            if isempty(fullpath)
                [fullpath, symName, fileType] = resolveFileName(name);
            end
            
            % If we still haven't found it, look for the name on
            % the path, if possible, and determine the file name that
            % contains it.
            if isempty(fullpath)
                [fullpath, symName] = resolveSymbolName(name);
            end
            
            % Remove the .m extension from symbol names, if present.
            % If we don't, it may confuse the analysis, leading us to
            % believe this is dot-qualified name. We know it isn't because
            % the name corresponds to a file name, which can't be
            % dot-qualified.
            symName = regexprep(symName,'\.(m|mlx)$','');
           
            % Make a symbol corresponding to the input name; don't 
            % presume to know the type (unless we've identified it as an
            % Extrinsic file).
            symbol = matlab.depfun.internal.MatlabSymbol(symName, ...
                             fileType, fullpath);
            % Ask the MatlabSymbol object to figure out its own type. This
            % operation is expensive, which is why it is not part of the 
            % constructor.
            if fileType == matlab.depfun.internal.MatlabType.NotYetKnown
                determineSymbolType(symbol, fsCache, addExc);
            end
        end
        
    end % Public static methods block
    
    methods
        
        function obj = MatlabInspector(r, t, fsCache, addDep, addClassDep, ...
                           addExclusion, addExpected, useDB, pickUserFiles)
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.MatlabInspector;
            import matlab.depfun.internal.MatlabSymbol;
            
            obj.BuiltinList = {};
            obj.Rules = r;
            obj.Target = t;
            obj.addDep = addDep;
            obj.addClassDep = addClassDep;
            obj.addExclusion = addExclusion;
            obj.addExpected = addExpected;
            obj.fsCache = fsCache;
            obj.useDB = useDB;
            obj.pickUserFiles = pickUserFiles;
			obj.isWin32 = strcmp(computer('arch'), 'win32');
            
            % Must construct new maps every time we build a new
            % MatlabInspector, because the maps depend on the MATLAB path, 
            % which could change between constructor calls.
            obj.BuiltinMethodInfo = buildMapOfFunctionsForBuiltinTypes;
            
        end
        
        function [symbolList, unknownType] = determineType(obj, name)
        % determineType Divide names into known and unknown lists. 
        
            % validate the file name before a further investigation
            isValidMatlabFileName(name);
        
            symbolList = {};
            unknownType = {};

            symbol = ...
                matlab.depfun.internal.MatlabInspector.resolveType(name, ...
                    obj.fsCache, obj.addExclusion);
            if symbol.Type ~= matlab.depfun.internal.MatlabType.NotYetKnown
                symbolList = symbol;
            else
                unknownType = symbol;
            end
        end

        function analyzeSymbols(obj, symbol)
            [F, S] = getSymbolNames(symbol.WhichResult);
            evaluateSymbols(obj, S, F, symbol);
        end

    end % Public methods

    methods(Access=private)
        
       %--------------------------------------------------------------
       function methodData = lookupBuiltinClassWithMethod(obj, symObj)
            if isKey(obj.BuiltinMethodInfo, symObj.Symbol)
                methodData = obj.BuiltinMethodInfo(symObj.Symbol);
            else
                methodData = struct('name',{},'location',{},'proxy',{});
            end
        end

        %--------------------------------------------------------------
        function recordExpected(obj, file, reason)
            obj.addExpected(file, reason)
        end

        %--------------------------------------------------------------
        function recordExclusion(obj, file, reason)
            obj.addExclusion(file, reason)
        end

        %----------------------------------------------------------------
        function symList = recordDependency(obj, client, symbol)
            symList = obj.addDep(client, symbol);
        end
        
        %----------------------------------------------------------------        
        function recordClassDependency(obj, client, sym)
            obj.addClassDep(client, sym);
        end
        
        %----------------------------------------------------------------        
        function tf = isMatlabFile(obj, filename)
            userFile = obj.pickUserFiles(filename);
            if isempty(userFile)
                tf = true;
            else
                tf = false;
            end
        end

        %--------------------------------------------------------------
        function evaluateSymbols(obj, symlist, localFuncList, client)
        % evaluateSymbols  Evaluate the m-tree symbols for a .m file
        %
        % Iterate over a list of symbols, looking for classes and functions.  A
        % symbol may be dot-qualified.  A class is identified when the symbol is
        % a class name or a dot-qualified static method or constant property
        % reference.  A function or script is identified when a symbol is not a
        % class, can be found on the path (as reported by WHICH), and can be
        % ruled out as a class method.

            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.ClassSet;
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.cacheExist;

            file = client.WhichResult;
            parentDir = MatlabSymbol.trimFullPath(file);
            [privateFiles, privateDirName] = getPrivateFiles(parentDir);
            % remove .m, .p, or .mex to get symbol names
			if obj.isWin32
				privateFiles = regexprep(privateFiles, ['\.(mlx|m|p|dll|' mexext ')$'], '');
            else
				privateFiles = regexprep(privateFiles, ['\.(mlx|m|p|' mexext ')$'], '');
			end
			
            % We spend a lot of time asking if a function is local.
            % Map lookup is about 20 times faster than cell-array search.
            lfMap = [];
            if ~isempty(localFuncList)
                lfMap = ...
                    containers.Map(localFuncList, true(size(localFuncList)));
            end
            
            % Asking about private functions is expensive too.
            pfMap = [];
            if ~isempty(privateFiles)
                pfMap = ...
                    containers.Map(privateFiles, true(size(privateFiles)));
            end
            
            % Let MatlabSymbol know about the new names, so that it can
            % add any that might represent class names to its list of 
            % classes. Calling WHICH here short-circuits the calls to 
            % which in the MatlabSymbol constructors.
            pathlist = cell(size(symlist));
            
            % For every symbol
            for k = 1:length(symlist)
                symName = symlist{k};
                % Ignore local function symbols 
                if (~isempty(lfMap) && ~isKey(lfMap, symName)) || isempty(lfMap)
                    pathlist{k} = cacheWhich(symName);
                   
                    % All these private functions are functions, but in
                    % order to properly classify them (to determine their
                    % status as proxies or principals) we must register
                    % the classes they might or might not belong to.
                    
                    if  ~isempty(pfMap) && isKey(pfMap, symName)
                        mlxFullPath = fullfile(privateDirName, [symName '.mlx']);
                        pFullPath = fullfile(privateDirName, [symName '.p']);
                        mFullPath = fullfile(privateDirName, [symName '.m']);
                        mexFullPath = fullfile(privateDirName, ...
                                               [symName '.' mexext]);
                        % Add both M-files and MEX files to the dependency
                        % list.
                        ex = cacheExist(mFullPath,'file');
                        if ex == 2 || ex == 6
                            svc = MatlabSymbol(symName, ...
                                       MatlabType.Function, mFullPath);
                            MatlabSymbol.registerClass(mFullPath);
                            recordDependency(obj, client, svc);
                        end
                            
                        if cacheExist(pFullPath,'file') == 6
                            % If M-code and P-code coexist, add both to the
                            % dependency closure.
                            svc = MatlabSymbol(symName, ...
                                       MatlabType.Function, pFullPath);
                            MatlabSymbol.registerClass(pFullPath);
                            recordDependency(obj, client, svc);
                        end
                        
                        if cacheExist(mexFullPath,'file') == 3
                            svc = MatlabSymbol(symName, ...
                                      MatlabType.Function, mexFullPath);
                            MatlabSymbol.registerClass(mexFullPath);
                            recordDependency(obj, client, svc);
                        elseif obj.isWin32
							dllFullPath = fullfile(privateDirName, [symName '.dll']);
							if cacheExist(dllFullPath,'file') == 2
                                svc = MatlabSymbol(symName, ...
										MatlabType.Function, dllFullPath);
                                    
                                MatlabSymbol.registerClass(dllFullPath);
								recordDependency(obj, client,svc);
                            end
                        end
                        
                        if cacheExist(mlxFullPath,'file') == 2
                            % If .mlx exists, ignore others.
                            recordDependency(obj, client, ...
                                  MatlabSymbol(symName, ...
                                       MatlabType.Function, mlxFullPath));                            
                        end
                    % Not a private file
                    else
                        if obj.useDB
                            % only analyze user files
                            if isempty(strfind(pathlist{k},'built-in')) && isMatlabFile(obj, pathlist(k))                    
                                continue;
                            end                    
                        end
                        
                        % Allow MatlabSymbol to make a guess at the symbol type
                        % Then, figure out the real symbol type
                        symObj = MatlabSymbol(symName, MatlabType.NotYetKnown, ...
                                              pathlist{k});
                        % Retrieve cached MatlabType information,
                        % if it has been analyzed before.
                        symObj.Type = obj.fsCache.Type(pathlist{k});
                        if isempty(symObj.Type) || ...
                                symObj.Type == MatlabType.NotYetKnown
                            symObj.Type = MatlabType.NotYetKnown;
                            determineSymbolType(symObj, obj.fsCache, obj.addExclusion);
                        end

                        % The name identifies a builtin function or class.
                        if isBuiltin(symObj)
                            % Might get duplicates, which will be unique-ified 
                            % out later. 
                            obj.BuiltinList{end+1} = symObj; 
                            if isClass(symObj) 
                                recordClassDependency(obj, client, symObj);
                            else
                                % Is it an extension method?
                                extMth = isExtensionMethod(symObj);
                                
                                % Check to see if overloads of the name exist for
                                % builtin types -- if so, record dependencies on
                                % those overloads. (These classes are already
                                % registered, no need to register them again.)
                                clsList = lookupBuiltinClassWithMethod(obj, symObj);
                                for o=1:numel(clsList)
                                    % If we're processing an extension
                                    % method, we must Allow the class
                                    % dependency, even if the class is 
                                    % Expected. The allow function requires
                                    % lists to be terminated with @!@.
                                    if extMth
                                        allowLiteral(obj.Rules,obj.Target, ...
                                            'COMPLETION', ...
                                            { clsList(o).proxy, '@!@' });
                                    end
                                    
                                    % Record a dependency on the builtin
                                    % class.
                                    bCls = MatlabSymbol(clsList(o).name, ...
                                              MatlabType.BuiltinClass, ...
                                              clsList(o).proxy);
                                          
                                    recordClassDependency(obj, client, bCls);
                                       
                                    % If the builtin class is sliceable,
                                    % record a dependency on the method as
                                    % well, since sliceable classes do not
                                    % proxy their methods.
                                    
                                    if isSliceable(bCls)
                                        bMth = MatlabSymbol(symObj.Symbol, ...
                                            MatlabType.ClassMethod, ...
                                            fullfile(clsList(o).location, ...
                                                     [symObj.Symbol '.m']));
                                        recordDependency(obj, client, bMth);
                                    end
                                          
                                end
                            end
                        elseif isUDDMethod(symObj) || isUDDPackageFunction(symObj)
                            recordClassDependency(obj, client, symObj);                            
                        elseif isMethod(symObj)
                            % only for MCOS or OOPS ClassMethod
                            recordDependency(obj, client, symObj);
                        elseif isClass(symObj) 
                            recordClassDependency(obj, client, symObj);
                        elseif isFunction(symObj)
                            % Symbol is a top-level function or package-based 
                            % function, or a script. Put the file name on the 
                            % list of files this file depends on.
                            recordDependency(obj, client, symObj);
                            clsList = ...
                                lookupBuiltinClassWithMethod(obj, symObj); 
                            for o=1:numel(clsList)
                                recordClassDependency(obj, client, ...
                                    MatlabSymbol(clsList(o).name, ...
                                    MatlabType.BuiltinClass, ...
                                    clsList(o).proxy));
                            end
                        end 
                    end % ! private files
                end % ! local functions
            end % for loop
        end % evaluateSymbols function
    end % Private methods block
end

% ================= Local functions =========================

%------------------------------------------------------------
function [fullpath, fcnName, fileType] = resolveFileName(name)
% resolveFileName If the name is a file, return file and function
    import matlab.depfun.internal.cacheWhich;
    import matlab.depfun.internal.cacheExist;

    fullpath = '';
    fcnName = '';
    fileType = matlab.depfun.internal.MatlabType.NotYetKnown;
    ex = cacheExist(name, 'file');
    if ex == 2 || ex == 3 || ex == 6
        pth = cacheWhich(name);
        if isempty(pth)
            % WHICH will annoyingly ignore non-MATLAB files without an
            % extension, unless explicitly told the file has no extension.
            % Extension or not, we know the file exists, because exists says it
            % does -- so add the empty extension if necessary.
            wname = name;
            if isempty(strfind(name,'.'))
                wname = [name '.'];
            end
            pth = cacheWhich(wname);
        end
        
        % Test for matching case by looking for the filename part of
        % the input name in the full path reported by which. If the cases
        % of the filename parts don't match, MATLAB won't call the
        % function, so we shouldn't include it in the Completion.
        [~,origFile,origExt] = fileparts(name);
        [~,foundFile,] = fileparts(pth);
        if strcmp(origFile, foundFile) == 1   % Case sensitive
            fullpath = pth;
            fcnName = foundFile;
        end
        
        % Check the extension -- if it is unknown, then this is an
        % Extrinsic file. Note: must use original extension here, because
        % WHICH returns empty for Extrinsic files.
        if ~isempty(origExt) && ...
           ~matlab.depfun.internal.MatlabInspector.knownExtension(origExt)
            fileType = matlab.depfun.internal.MatlabType.Extrinsic;
        end
    elseif ex == 7
        fullpath = name;
    end
end

%------------------------------------------------------------
function [fullpath, symName] = resolveSymbolName(symName)
% resolveSymbolName Given a full or partial symbol name, fully expand it.
% At this point, full expansion means locating the file that contains
% the symbol and canonicalizing the full path of that file according
% to the current platform. File / function name mapping is case 
% sensitive.
%
% Look for the symbol on the path and under MATLAB root. Make sure the
% returned file is not a directory.

    import matlab.depfun.internal.MatlabSymbol;
    import matlab.depfun.internal.cacheWhich;
    import matlab.depfun.internal.cacheExist;
    
    fullpath = '';
    partialPath = false;
    dotQualified = false;
            
    % Does the file name point to an existing file?
    if ~cacheExist(symName,'file')
        % No. Try to find the name with which.
        pth = cacheWhich(symName);
        
        % Three possible cases:
        %   * symName contains the trailing part of a partial file name.
        %   * symName contains a dot-qualified name of a function or class.
        %   * symName is garbage -- unresolvable.        

        dots = strfind(symName, '.');
        start = length(pth) - length(symName);
        % If the WHICH-result contains the symName, symName was a partial
        % path.
        if start > 0 && strncmpi(pth(start:end),symName,length(symName))
            % Check case -- which inexplicably ignores case when looking for 
            % file names, but strfind performs a case-sensitive check. 
            if ~isempty(strfind(pth, symName))
                partialPath = true;
            end
        elseif ~isempty(dots)
            dotQualified = true;
        end
        
        % If the symbol name is a partial path or a dot-qualified name, it
        % is valid and we can accept the WHICH-result as the path to the
        % defining file.
        if partialPath || dotQualified
            fullpath = pth;
        end
        % Didn't work. Look for the file under MATLAB root.
        if isempty(fullpath)
            pth = fullfile(matlabroot,symName);
            % Ensure file / function name case match.
            ex = cacheExist(pth, 'file');
            if (ex == 2 || ex == 6) && strfind(pth, symName)
                fullpath = pth;
            else
                fullpath = '';
            end
        end
        
        % G883993: manage undocumented built-in
        if isempty(fullpath) && exist(symName,'builtin') == 5
            fullpath = cacheWhich(symName);
        end
    else             
        % Make sure file is specified with platform-conformant
        % path separators. (If not, WHICH and EXIST will perform
        % inconsistently.
        if ispc
            fullpath = strrep(symName,'/', filesep);
        else
            fullpath = strrep(symName,'\',filesep);
        end
        
        % Try to discover full path to file using which. If which
        % can't find the file, then just use what we were given.
        where = cacheWhich(fullpath);
        if ~isempty(where) 
            fullpath = where;
        end
        % If the full path does not contain a case sensitive match to
        % the function name, we didn't resolve the function, despite what 
        % WHICH and EXIST might think.
        match = ~isempty(strfind(fullpath, symName));
        if ~match
            fullpath = '';
        end
    end

    % Check for invalid results -- we must find some file, and that
    % file must not be a directory.
    if isempty(fullpath)
        error(message('MATLAB:Completion:NameNotFound',symName));
    elseif exist(fullpath, 'dir') == 7
        error(message('MATLAB:Completion:NameIsADirectory',symName));
    end
    
    builtinStr = 'built-in ';
    if strncmp(fullpath,builtinStr,length(builtinStr))
        [~,symName,~] = fileparts(MatlabSymbol.getBuiltinPath(fullpath));
    else
        % Dot qualified names are their own symbols.
        if ~dotQualified
            [~,symName,~] = fileparts(fullpath);
        end
    end
end

%------------------------------------------------------------
function determineSymbolType(symbol, fsCache, addExc)
    try
        determineMatlabType(symbol);        
    catch exception
        % only catch the error thrown by meta.class.fromName()
        if strcmp(exception.identifier, 'MATLAB:class:InvalidSuperClass')
            % add the file to the exclusion file, because its super class
            % cannot be found on the path.
            reason = struct('identifier', exception.identifier, ...
                            'message', exception.message, ...
                            'rule', '');
            addExc(symbol.WhichResult, reason);
            symbol.Type = matlab.depfun.internal.MatlabType.Ignorable;
        else
            rethrow(exception);
        end
    end
    
    % Only cache the type if the symbol is the entry point or class name.
    %
    % TODO: Add MCOSMethod to MatlabType, and make this code faster by
    % checking the type.
    if ~isempty(symbol.Symbol)
        dotIdx = strfind(symbol.Symbol,'.');
        baseSym = symbol.Symbol;
        if ~isempty(dotIdx)
            baseSym = baseSym(dotIdx(end)+1:end);
        end
        if ~isempty(symbol.WhichResult)
            % Remove extension, if any
            noExt = symbol.WhichResult(1:end-numel(symbol.Ext));
            loc = strfind(noExt, baseSym);
            % Is the baseSym the last part of the baseFile?
            if ~isempty(loc)
                loc = loc(end);
                if loc == numel(noExt) - numel(baseSym) + 1
                    cacheType(fsCache, symbol.WhichResult, symbol.Type);
                end
            end
        end
    end
end

%----------------------------------------------------------------
function fcnMap = buildMapOfFunctionsForBuiltinTypes
% buildMapOfFunctionsForBuiltinTypes Record full paths of builtin methods
%
%   map(function.m) -> list of class names and containing directories
%
%     fcnMap(f).name -> class name symbol, suitable for MatlabSymbol
%     fcnMap(f).location -> cell array of class directories, one per class
%         that overloads the function.
    import matlab.depfun.internal.cacheWhich;

    numTypes = length(matlab.depfun.internal.MatlabInspector.BuiltinClasses);
    fcnMap = containers.Map;
    % For each builtin type
    for k=1:numTypes
        % Get the name of a builtin type (from the static list)
        aType = matlab.depfun.internal.MatlabInspector.BuiltinClasses{k};
             
        % Find all the methods for that type
        whatResults = what(['@' aType]);
        if ~isempty(whatResults) 
            % For each directory containing methods of aType
            % TODO: Extend to all executable extensions.
            for n=1:length(whatResults)
                fcn = whatResults(n).m ;
                % For each method in the directory
                for j=1:length(fcn)
                    [~,key,~] = fileparts(fcn{j});  % Strip off .m
                    
                    % Add an entry to each map. Each method name maps to
                    % a structure array. 
                    % 
                    % The name field stores the names of the classes that 
                    % overload the function.
                    %
                    % The location field is a cell array of locations where
                    % the overloading function occurs.
                    
                    fcnInfo.name =  aType;
                    fcnInfo.proxy = cacheWhich(aType);
                    fcnInfo.location = whatResults(n).path;
                    if isempty(fcnInfo.proxy)
                        fcnInfo.proxy = [...
                         'built-in (' strrep(fcnInfo.location, '@', '') ')'];
                    end 
                    
                    if isKey(fcnMap, key)
                       fcnMap(key) = [ fcnMap(key) fcnInfo ];
                    else
                        fcnMap(key) = fcnInfo;
                    end
                end
            end
        end
    end
end

%-------------------------------------------------------------
function extMap = initKnownExtensions()
% Create a containers.Map with file extensions as keys, for fast lookup.
    mext = mexext('all');
    extList = cellfun(@(e)['.' e], { mext.ext }, 'UniformOutput', false );
    extList = [ extList, { '.m', '.p', '.mat', '.fig', '.mlx' } ];
    extMap = containers.Map(extList, true(size(extList)));
end

%--------------------------------------------------------------
function isValidMatlabFileName(name)
    [~,fname,ext] = fileparts(name);
    if (~isempty(fname) && (fname(1)=='.') ...
        && any(strcmp({'.m' '.p' '.mlx'}, ext)))
        error(message('MATLAB:Completion:InvalidFileName', name));
    end
end
