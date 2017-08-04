classdef DependencyDepot < handle
    properties
        dbName
        Target
        Component
    end

    properties (Access = private)
        SqlDBConnObj 
        Language2ID
        ID2Language        
        FileSep = filesep;
        MatlabRoot = matlabroot;
        tableData = init_db_table_data;
        fileClassifier  % Simple file classification based on file extension
        protectedLocations % Cache of protected locations
        isPC
    end

	methods

        function obj = DependencyDepot(DBName)
            % Input must be a string
            if ~ischar(DBName)
                error(message('MATLAB:Completion:InvalidInputType', ...
                    1, class(DBName), 'char'));
            end
            
            % fullpath of the database
            obj.dbName = DBName;

            % Create a database connector object.
            obj.SqlDBConnObj = matlab.depfun.internal.database.SqlDbConnector;
            
            % create a new database if it doesn't exist yet.
            created = false;
            if ~exist(obj.dbName,'file')
                created = true;
                obj.SqlDBConnObj.createDatabase(obj.dbName);
            end

            % connect to the database
            obj.SqlDBConnObj.connect(obj.dbName);
            
            % if we just created the database, initialize the tables.
            if created
                obj.createTables();
            end

            obj.fileClassifier = matlab.depfun.internal.FileClassifier;
            obj.isPC = ispc;
        end

        function disconnect(obj)
            obj.SqlDBConnObj.disconnect();
        end
        
        function result = fetchNonEmptyRow(obj)
        % Fetch a row that is not expected to be empty.
        % If it is empty, report an error.
            result = obj.SqlDBConnObj.fetchRow();
            if isempty(result)
                error(message('MATLAB:Completion:EmptyFetchResult'));
            end
        end
        
        function result = fetchNonEmptyRows(obj)
        % Fetch a set of rows that is not expected to be empty.
        % If it is empty, report an error.
            result = obj.SqlDBConnObj.fetchRows();
            if isempty(result)
                error(message('MATLAB:Completion:EmptyFetchResultList'));
            end
        end
        
        function count = recordFileData(obj, symList, firstID)
        % Bulk insert the files that the symbols represent. File IDs of the
        % new files will range from firstID to firstID + length(symList) - 1.
            
            BuiltinClassID = ...
                int32(matlab.depfun.internal.MatlabType.BuiltinClass);

            BuiltinFunctionID = ...
                int32(matlab.depfun.internal.MatlabType.BuiltinFunction);
            
            MatlabID = obj.Language2ID('MATLAB');
            CppID = obj.Language2ID('CPP');
            
            numSym = length(symList);

            % Extract file table data from the symbol list.
            fileID = firstID:firstID+numSym-1;
            Type = [symList.Type];
            TypeID = int32(Type);
            
            LanguageID = ones(1, numSym) .* MatlabID;
            BuiltinIdx = logical(TypeID==BuiltinClassID | ...
                                 TypeID==BuiltinFunctionID);
            LanguageID(BuiltinIdx) = CppID;

            % only save relative path to the matlabroot for transplanability
            WhichResult = strrep({symList.WhichResult}, ...
                                 [obj.MatlabRoot obj.FileSep], '');

            % canonical path
            WhichResult = strrep(WhichResult, obj.FileSep, '/');
            Symbol = {symList.Symbol};
            
            % Insert the files into the file table; bulk insert for 
            % performance.
            obj.SqlDBConnObj.insert('File', 'ID', fileID, ...
                'Path', WhichResult, 'Language', LanguageID, ...
                'Type', TypeID, 'Symbol', Symbol);

            count = numSym;

        end

        function recordProxyData(obj, proxySymbols)
        % Fill in the Proxy_Principal table. Each row in the table
        % represents a single proxy -> principal relationship. There are at
        % least as many rows in the table as there are principals. There
        % may be more rows, if multiple proxies represent the same
        % principals.
        %
        % To fill in the table, we create two vectors of the same size,
        % proxyID and principalID. Since we're creating the table here, we
        % can deduce the IDs apriori, which is much faster than querying
        % the database.
        % 
            principalSymbols = matlab.depfun.internal.MatlabSymbol.empty(1,0);
            proxyID = [];
            principalID = [];
            k = 1;
            expandedProxy = containers.Map('KeyType','char',...
                                  'ValueType','logical');
            % TODO: Consider moving this loop into a method owned by
            % Completion. buildTraceList may need something like it.
            for symbol = proxySymbols
                pList = principals(symbol);
                if ~isempty(pList) 
                    % Store proxy names as full paths without extension, 
                    % so we can detect, for example, when a .p and .m file 
                    % represent the same principals.
                    %
                    % Why does this matter? Because the file list in the
                    % database cannot have duplicate entries. Therefore,
                    % the files in the principal list must be unique.
                    %
                    % In the case of a built-in, try to find the class
                    % directory on the path and use that for a key.
                    proxyName = proxyLocation(symbol);
                     
                    if isKey(expandedProxy, proxyName)
                        % Find the IDs of the principals (already
                        % assigned) by finding the locations of the
                        % principals in the principalSymbols list.
                        newPrincipals = zeros(1,numel(pList));
                        principalPaths = {principalSymbols.WhichResult};
                        for n=1:numel(pList)
                            matchP = strcmp(pList(n).WhichResult, ...
                                            principalPaths);
                            id = find(matchP);
                            newPrincipals(n) = id;
                        end
                        % Proxy ID well known: k. 
                        newProxy = ones(1,numel(pList)) .* k;
                    else
                        % Remember that we've expanded this proxy already.
                        expandedProxy(proxyName) = true;
                        
                        % Remember the IDs of the proxy and its principals.
                        % This code assumes files are inserted into the
                        % database in the same order as they appear in the
                        % array.
                        pCount = numel(principalSymbols);
                        newPrincipals = (1:numel(pList)) + pCount;
                        newProxy = ones(1,numel(newPrincipals)) .* k;
   
                        principalSymbols = [principalSymbols pList]; %#ok
                    end
                    proxyID = [proxyID newProxy];  %#ok
                    principalID = [ principalID newPrincipals ]; %#ok
                end
                k = k + 1;
            end
            
            % Add the principals to the file table. By definition, the
            % principal set and the proxy set have an empty intersection.
            if ~isempty(principalSymbols)

                recordFileData(obj, principalSymbols, numel(proxySymbols)+1);

                % Offset the principal IDs by the number of proxies, since
                % the first principal ID is numel(proxySymbols) + 1.
                principalID = principalID + numel(proxySymbols);
                
                % Bulk insert
                obj.SqlDBConnObj.insert('Proxy_Principal', ...
                                        'Proxy', proxyID, ...
                                        'Principal', principalID);
            end
        end

        function recordDependency(obj, target, graph, component)
        % Write the level-0 dependency to the database

            obj.Target = target;
            obj.Component = component;

            % Clear out all the file dependency data.
            obj.clearFileTables();
                
            % Insert file information to table File            
            % modifications for performance, g904544
            % (1) cache Language table
            cacheLanguageTable(obj);

            % If the graph is empty, stop. Do nothing else.
            if isempty(graph) || graph.VertexCount == 0
                return;
            end

            % (2) use bulk insert
            % retrieve data from each vertex in the graph
            symList = partProperty(graph, 'Data', 'Vertex');
            symList = [symList.symbol];

            % Fill in the file table
            numFiles = obj.recordFileData(symList, 1);

            % Insert level-0 dependency to table Level0_Use_Graph
            obj.recordEdges(graph, 'Level0_Use_Graph');

            % Insert principal/proxy data.
            obj.recordProxyData(symList);

        end

        function recordClosure(obj, graph)
            % Insert transitive closure to table Proxy_Closure
            obj.recordEdges(graph, 'Proxy_Closure');            
        end

        function graph = getDependency(obj, component, target)
        % Return level-0 dependency
        % graph = getDependency(obj [,component] [,target])

            % create a graph based on File and Level0_Use_Graph tables
            graph = obj.createGraphAndAddEdges('Level0_Use_Graph');
        end

        function graph = getClosure(obj, component, target)
        % Return full closure
        % graph = getClosure(obj [,component] [,target])

            % create a graph based on File and Proxy_Closure tables
            graph = obj.createGraphAndAddEdges('Proxy_Closure');
        end

        function fileList = getFile(obj, component, target)
        % fileList = getFile(obj [, component] [, target])

            obj.SqlDBConnObj.doSql('SELECT ID, Path from File;');
            % bulk select
            rawList = obj.SqlDBConnObj.fetchRows();
            num_files = numel(rawList);
            % pre-allocation for the struct array
            fileList(num_files).fileID = [];
            fileList(num_files).path = '';
            for i = 1:num_files
                fileList(i).fileID = rawList{i}{1};
                if obj.isfullpath(rawList{i}{2})
                    fileList(i).path = rawList{i}{2};
                else
                    fileList(i).path = [strrep(obj.MatlabRoot,obj.FileSep,'/') '/' rawList{i}{2}];
                end
            end
        end

        function tf = requires(obj, client, service)
        % Does the client require the service? Client or service may be a 
        % "set" -- the other argument must be a scalar. Data type: numeric
        % IDs or string file names.

            if iscell(client) && iscell(service)
                error(message('MATLAB:Completion:DuplicateArgType', ...
                              class(client), 1, 2, class(client)));
            end

            if isnumeric(client)
                clientID = client;
            else
                clientID = lookupPathID(obj, client);
            end
            if isnumeric(service)
                serviceID = service;
            else
                serviceID = lookupPathID(obj, service);
            end

            if numel(serviceID) > 1
                serviceSet = sprintf('%d,', serviceID);
                serviceSet(end) = []; % Chop off trailing comma
                q = sprintf(['SELECT Dependency FROM Proxy_Closure ' ...
                             'WHERE Client = %d AND Dependency IN (%s)'], ...
                            clientID, serviceSet);
                targetID = serviceSet;
            elseif numel(clientID) > 1
                clientSet = sprintf('%d,', clientID);
                clientSet(end) = []; % Chop off trailing comma
                q = sprintf(['SELECT Dependency FROM Proxy_Closure ' ...
                             'WHERE Client IN (%s) AND Dependency = %d'], ...
                            clientSet, serviceID);
                targetID = serviceID;
            end
            obj.SqlDBConnObj.doSql(q);
            inClosure = cellfun(@(r)r{1}, obj.SqlDBConnObj.fetchRows);
            tf = ismember(targetID, inClosure);
        end

        function [list, notFoundList] = requirements(obj, files)
            if ~iscell(files)
                files = { files };
            end
            % convert to canonical path relative to matlabroot            
            normalized_path = normalizeFiles(obj, files);
            notFoundList = struct([]);
            DepList = cell(1,numel(normalized_path)*2);
            n = 1;
            for i = 1:numel(normalized_path)
                obj.SqlDBConnObj.doSql(sprintf( ...
                    ['SELECT ID ' ...
                     'FROM File ' ...
                     'WHERE Path = ''%s'';'], normalized_path{i}));
                ClientID = obj.SqlDBConnObj.fetchRow();
                if ~isempty(ClientID)
                    % put client itself on the list
                    DepList{n} = ClientID; 
                    n = n + 1;

                    % number of dependencies
                    obj.SqlDBConnObj.doSql(sprintf( ...
                        ['SELECT Dependency ' ...
                         'FROM Proxy_Closure ' ...
                         'WHERE Client = %d;'], ClientID));
                    DependencyID = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
                    if ~isempty(DependencyID)
                        DepList{n} = DependencyID';
                        n = n + 1;
                    end
                else
                    notFoundList(end+1).name = 'N/A';
                    notFoundList(end).type = 'N/A';
                    notFoundList(end).path = strrep(files{i}, obj.FileSep, '/');
                    notFoundList(end).language = 'N/A';
                end
            end
            DepList = unique(cell2mat(DepList(1:n-1)));
            
            % Find all proxy types. 
            q = ['SELECT Symbol_Type.Value FROM Symbol_Type,Proxy_Type ' ...
                 'WHERE Symbol_Type.ID = Proxy_Type.Type'];
            obj.SqlDBConnObj.doSql(q);
            proxy_types = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
   
            % A helper function
            function tf = isProxy(fileID)
                tf = false;
                obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT Type ' ...
                             'FROM File WHERE ID = %d;'], fileID));
                typeID = obj.SqlDBConnObj.fetchRow();
                if ~isempty(typeID)
                    tf = any(proxy_types == typeID);
                end
            end
            proxyIdx = arrayfun(@(id)isProxy(id), DepList);
            % Remove non-proxy entries
            proxy = DepList(proxyIdx);
            
            % If a file is a proxy, retrieve its principals.
            num_proxy = length(proxy);
            if num_proxy > 0
                % principalID is a 1-by-num_proxy cell array.
                % Each cell is a 1-by-x array containing IDs of x
                % principals.
                principalID = arrayfun(@(id)obj.retrievePrincipals(id)',...
                                       proxy, 'UniformOutput', false);
                                   
                % Remove empty matrices from the principalID array before
                % converting to matrix (or cell2mat will whinge).
                keep = ~cellfun('isempty', principalID);
                principalID = principalID(keep);
                
                % Reshape it to be a 1-by-x double array
                principalID = cell2mat(principalID);

                % Append principals to the dependency list
                DepList = unique([DepList principalID]);
            end
            
            % build the trace list below
            total_num_dep = length(DepList);

            if ~isempty(DepList)
                if isempty(obj.ID2Language)
                    cacheLanguageTable(obj);
                end
            end
            
            % pre-allocation for the dependency list
            if total_num_dep > 0
                list(total_num_dep).name = '';
                list(total_num_dep).type = '';
                list(total_num_dep).path = '';
                list(total_num_dep).language = '';                
            else
                list = struct([]);
            end
            
            for i = 1:total_num_dep
                obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT Symbol, Type, Path, Language ' ...
                             'FROM File WHERE ID = %d;'], DepList(i)));
                [name, typeId, path, langId] = obj.SqlDBConnObj.fetchRow();
                
                % convert typeID and langID to string
                type = char(matlab.depfun.internal.MatlabType(typeId));                
                lang = obj.ID2Language(langId);

                % build trace list
                list(i).name = name;
                list(i).type = type;
                if obj.isfullpath(path)
                    list(i).path = path;
                else
                    list(i).path = [strrep(obj.MatlabRoot, ...
                                    obj.FileSep,'/') '/' path];
                end
                list(i).language = lang;
            end
            
            % combine DepList and NotFoundList
            % Files on the MatlabFile list are valid existing files based on the
            % WHICH result in PickOutUserFiles() in Completion.m, so they
            % should be on the return list, though they might not be in the
            % call closure table. (For example, files on the Inclusion list 
            % are often not found in the call closure table.)
            list = [list notFoundList];
        end
        
        function result = getflattenGraph(obj, request)
        % retrieve file list and level-0 call closure from the database
            switch request
                case 'file'
                    obj.SqlDBConnObj.doSql('SELECT Path from File;');
                    result = decell(obj.SqlDBConnObj.fetchRows());
                case 'type'
                    obj.SqlDBConnObj.doSql('SELECT Type from File;');
                    result = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
                case 'symbol'
                    obj.SqlDBConnObj.doSql('SELECT Symbol from File;');
                    result = decell(obj.SqlDBConnObj.fetchRows());
                case 'call_closure'            
                    obj.SqlDBConnObj.doSql('SELECT Client from Level0_Use_Graph;');
                    client = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
                    obj.SqlDBConnObj.doSql('SELECT Dependency from Level0_Use_Graph;');
                    dependency = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
                    result = [client dependency];
                otherwise
                    result = [];
            end
        end
        
        function recordFlattenGraph(obj, target, component, FileList, ...
                                    TypeID, Symbol, CallClosure, TClosure)
        % Write the flatten graph to the database
        
            obj.Target = target;
            obj.Component = component;
           
            % Insert file information to table File            
            % modifications for performance, g904544
            % (1) cache Language table
            cacheLanguageTable(obj);
            
            BuiltinClassID = int32(matlab.depfun.internal.MatlabType.BuiltinClass);
            BuiltinFunctionID = int32(matlab.depfun.internal.MatlabType.BuiltinFunction);
            
            MatlabID = obj.Language2ID('MATLAB');
            CppID = obj.Language2ID('CPP');
            
            % (2) use bulk insert
            % retrieve data from each vertex in the graph
            numFile = length(FileList);            
            FileID = 1:numFile;
            
            LanguageID = ones(1, numFile) .* MatlabID;
            BuiltinIdx = logical(TypeID==BuiltinClassID | TypeID==BuiltinFunctionID);
            LanguageID(BuiltinIdx) = CppID;
            
            % write to the database; insert the data at once
            obj.SqlDBConnObj.insert('File', 'ID', FileID, ...
                'Path', FileList, 'Language', LanguageID, ...
                'Type', TypeID, 'Symbol', Symbol);
            
            % insert level-0 call closure to Level0_Use_Graph
            obj.SqlDBConnObj.insert('Level0_Use_Graph', ...
                'Client', CallClosure(:,1), 'Dependency', CallClosure(:,2));
            
            % Insert full closure edges into Proxy_Closure table. Since this 
            % can be a long list, be careful about memory usage. Don't ask the
            % closure object for more memory than MATLAB can provide. Pay
            % attention to both the total amount of memory available and the
            % largest contiguous block.

            % To further increase performance, turn off journalling for this
            % series of SQL commands. Drawback: system failure during this 
            % time will result in a corrupt database. Saving throw:
            % the database isn't complete yet, and is just as unusable as if it
            % were corrupt.

            edgeCount = TClosure.EdgeCount;
            vID = feval(TClosure.VertexIdType,0);
            vIdData = whos('vID');
            edgeBytes = vIdData.bytes * 2;
            offset = 0;
            obj.SqlDBConnObj.doSql('PRAGMA journal_mode = OFF');

            % Make something up. Something reasonable. On non-Windows machines,
            % set this value so that we try to allocate enough memory to get
            % all the edges at once. This will likely succeed, but see the 
            % code in the the loop below that reduces this value if we get
            % an out of memory error.
            mem.MaxPossibleArrayBytes = edgeCount * edgeBytes * 4;

            while (offset < edgeCount)
                % How much memory is available? MATLAB is only willing to
                % answer this question on Windows.
                if obj.isPC
                    mem = memory;
                end
                % Take a chunk a little bit less than one-third the size 
                % of the largest available; we'll use the rest expanding 
                % the IDs to int64.
                maxArray = floor(mem.MaxPossibleArrayBytes / 3.14159);
                % How many edges fit into that chunk?
                maxEdges = maxArray / edgeBytes;

                % Get all the edges that will fit.
                try
                    edges = TClosure.EdgeRange(offset, maxEdges);
                    % Convert zero-based graph vertex IDs to one-based database 
                    % vertex IDs. Here's the first copy, and a possible widening.
                    edges = edges + 1;
                    if strcmp(computer('arch'),'win32')
                        edges = int32(edges);  % maxArray is 
                    else
                        edges = int64(edges);  % Database can't handle uint32.
                    end
                    % Write the edges into the database Proxy_Closure table.
                    % Making another copy.
                    obj.SqlDBConnObj.insert('Proxy_Closure', ...
                       'Client', edges(:,1), 'Dependency', edges(:,2));
                    % Hopefully return the memory to MATLAB for reuse in the 
                    % next iteration.
                    clear edges
                catch ex
                    % Was this an out of memory error? Reduce
                    % memory demand and trying again.
                    if strcmp(ex.identifier, 'MATLAB:nomem')
                        if ~obj.isPC
                            mem.MaxPossibleArrayBytes = ... 
                                mem.MaxPossibleArrayBytes * .75;
                        end
                        if mem.MaxPossibleArrayBytes < edgeBytes
                            rethrow(ex);
                        end
                        continue;
                    else
                        % Not out of memory -- rethrow it.
                        rethrow(ex);
                    end
                end

                % Increment the starting offset (distance from the first
                % element).
                offset = offset + maxEdges;
            end

            % For performance, create a coverage index for Proxy_Closure.
            % This is expensive (it almost doubles the size of the database),
            % but it makes queries Proxy_Closure queries much faster.
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Proxy_Closure_Index ON ' ...
                'Proxy_Closure(Client,Dependency)']);

            % We also spend a lot of time checking component membership, so
            % create a composite index table for the Component_Membership
            % table. In one test, this resulted in a 42x increase in speed.
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Component_Membership_Index ON ' ...
                'Component_Membership(File,Component)']);

            obj.SqlDBConnObj.doSql('PRAGMA journal_mode = ON'); 
        end
        
        function recordExclusion(obj, target, file)
        % save in Exclusion_List based on 'target' for 'file'
            related_tables = {'Exclusion_List', 'Exclude_File'};
            cellfun(@(t)obj.clearTable(t), related_tables);
        
            if ~ischar(target)
                % convert matlab.depfun.internal.Target to string
                target = matlab.depfun.internal.Target.str(target);
            end
            
            obj.SqlDBConnObj.doSql(sprintf('SELECT ID FROM Target WHERE Name = ''%s'';', target));
            targetID = obj.fetchNonEmptyRow();
            
            obj.SqlDBConnObj.insert('Exclude_File', 'Path', file);
            
            file = normalizeFiles(obj, file);
            num_file = numel(file);
            for i = 1:num_file              
                obj.SqlDBConnObj.doSql(sprintf(...
                    'SELECT ID from Exclude_File where Path = ''%s'';', ...
                    file{i}));

                fileID = obj.SqlDBConnObj.fetchRow();                

                % Insert the file into the Exclude_File table if necessary
                if isempty(fileID)
                    obj.SqlDBConnObj.doSql(sprintf(...
                        'INSERT INTO Exclude_File (Path) VALUES (''%s'');',...
                        file{i}));
                    
                    obj.SqlDBConnObj.doSql(sprintf(...
                        'SELECT ID FROM Exclude_File WHERE Path = ''%s'';',...
                        file{i}));

                    fileID = obj.SqlDBConnObj.fetchRow();
                end

                obj.SqlDBConnObj.doSql(sprintf(...
          'INSERT INTO Exclusion_List (Target, File) VALUES (%d, %d);', ...
                    targetID, fileID));
            end
        end
        
        function bData = getBuiltinData(obj, target, moduleLocation)
        % Return a structure array containing all the builtin data. If
        % moduleLocation is specified, retrieve only the builtin data for
        % modules at those locations.
        % 
        % module  : char
        % location: char
        % builtins: struct array
        %      symbol   : char
        %      type     : int
        %      signature: char
        %      location : char

            requireTable(obj, 'Builtin_Symbol');

            % Form the SQL query
            sql = 'SELECT ID,Name,Location FROM Builtin_Module';
            
            if nargin == 3 && ~isempty(moduleLocation)
                if ischar(moduleLocation)
                    moduleLocation = { moduleLocation };
                end
                where = [' WHERE Location = ''' moduleLocation{1} ''''];
                or = '';
                if numel(moduleLocation) > 1
                    or = sprintf(' OR Location = ''%s''', ...
                                 moduleLocation{2:end});
                end
                sql = [sql where or];
            end  
            
            % Retrieve data
            obj.SqlDBConnObj.doSql(sql);
            
            % Cell array of {id, name, location} cell arrays.
            moduleData = obj.SqlDBConnObj.fetchRows();
            
            % For each module, get all its builtins
            function mData = getModuleBuiltins(id_name_loc, db)
                modID = id_name_loc{1}; 
                name = id_name_loc{2};
                location = id_name_loc{3};

                mData.module = name;
                mData.location = location;
                
                % Select all the builtins from the given module
                modIdStr = sprintf('%d',modID);
                sql = [...
                    'SELECT ID,Symbol,Type FROM Builtin_Symbol ' ...
                    'WHERE Builtin_Symbol.Module = ' modIdStr ];
                db.doSql(sql);
                symData = db.fetchRows;
                % Build a map (hash) of builtins, indexed by ID
                bMap = containers.Map('KeyType', 'int64', 'ValueType', 'any');
                for k=1:numel(symData)
                    b.symbol = symData{k}{2};
                    b.type = symData{k}{3};
                    % Empty fields so structures will be uniform and can be
                    % concatenated.
                    b.signature = '';
                    b.location = '';
                    bMap(symData{k}{1}) = b;
                end
                
                % Get signature data, for builtins that have it.
                db.doSql([...
                    'SELECT Builtin_Symbol.ID,Signature.Signature ' ...
                    'FROM Builtin_Symbol,Signature,Builtin_Signature ' ...
                    'WHERE Builtin_Symbol.Module = ' modIdStr ' ' ...
                    'AND Builtin_Symbol.ID = Builtin_Signature.Builtin ' ...
                    'AND Builtin_Signature.Signature = Signature.ID' ]);
                sData = db.fetchRows;
                for k=1:numel(sData)
                    b = bMap(sData{k}{1});
                    b.signature = sData{k}{2};
                    bMap(sData{k}{1}) = b;
                end

                % Get location data for builtins that have it.
                db.doSql([...
                    'SELECT Builtin_Symbol.ID,Path_Item.Location ' ...
                    'FROM Builtin_Symbol,Path_Item,Builtin_Path ' ...
                    'WHERE Builtin_Symbol.Module = ' modIdStr ' ' ...
                    'AND Builtin_Symbol.ID = Builtin_Path.Builtin ' ...
                    'AND Builtin_Path.Path = Path_Item.ID' ]);
                pData = db.fetchRows;
                for k=1:numel(pData)
                    b = bMap(pData{k}{1});
                    b.location = pData{k}{2};
                    bMap(pData{k}{1}) = b;
                end

                % Keep the values in the map -- no need for the keys
                v = values(bMap);
                mData.builtins = [ v{:} ];
            end
            
            bData = cellfun(@(m)getModuleBuiltins(m,obj.SqlDBConnObj), ...
                              moduleData);
            
        end

        function clearBuiltinData(obj, target)
        % Clear all the builtin data. If optional TARGET is specified, then
        % clear only builtin data for that target.
        
            % First, remove the builtin location entries from the
            % Path_Items table. To reduce the number of queries, batch the
            % deletes together using '...WHERE ID IN (...)'.
            
            obj.SqlDBConnObj.doSql('SELECT Path FROM Builtin_Path');
            pthID = cellfun(@(r)r{1}, obj.SqlDBConnObj.fetchRows);
            
            maxDeleteCount = 128;
            idCount = numel(pthID);
            loopCount = ceil(idCount / maxDeleteCount);
            rangeBegin = 1; 
            for k=loopCount
                rangeEnd = min(k*maxDeleteCount, idCount);
                idRange = pthID(rangeBegin:rangeEnd);
                idStr = sprintf('%d,', idRange);
                idStr(end) = ''; % Chop off extraneous trailing comma
                obj.SqlDBConnObj.doSql(...
                    ['DELETE FROM Path_Item WHERE ID IN (' idStr ')']);
                rangeBegin = rangeBegin + maxDeleteCount;
            end
            
            % Delete and recreate the builtin tables.        
            builtinTables = {'Builtin_Symbol', 'Signature', ...
                          'Builtin_Module', 'Builtin_Path', ...
                          'Component_Builtin_Module', 'Builtin_Signature'};
            cellfun(@(t)obj.clearTable(t), builtinTables); 
            
        end
        
        function [loc, name] = getBuiltinModuleInfo(obj, varargin)
        % Retrieve the names and locations of all known builtin modules.
        
            if nargin == 2 && isscalar(varargin{1})
                cIdx = varargin{1};
            end
        
            if nargin == 1
                sql = 'SELECT Location FROM Builtin_Module';
            elseif nargin == 2 
                sql = sprintf(['SELECT Builtin_Module.Location ' ...
                'FROM Builtin_Module ' ...
                'WHERE Builtin_Module.ID IN ' ...
                '    (SELECT Builtin_Module.ID ' ...
                '     FROM Builtin_Module, Component, Component_Builtin_Module ' ...
                '     WHERE Component.ID = %d ' ...
                '     AND Component.ID = Component_Builtin_Module.Component ' ...
                '     AND Builtin_Module.ID = Component_Builtin_Module.Module);'], ...
                cIdx);
            end        
            obj.SqlDBConnObj.doSql(sql);
            loc = decell(obj.SqlDBConnObj.fetchRows);
            
            if nargout == 2
                if nargin == 1
                    sql = 'SELECT Name FROM Builtin_Module';
                elseif nargin == 2 
                    sql = sprintf(['SELECT Builtin_Module.Name ' ...
                'FROM Builtin_Module ' ...
                'WHERE Builtin_Module.ID IN ' ...
                '    (SELECT Builtin_Module.ID ' ...
                '     FROM Builtin_Module, Component, Component_Builtin_Module ' ...
                '     WHERE Component.ID = %d ' ...
                '     AND Component.ID = Component_Builtin_Module.Component ' ...
                '     AND Builtin_Module.ID = Component_Builtin_Module.Module);'], ...
                cIdx);
                end
                obj.SqlDBConnObj.doSql(sql);
                name = decell(obj.SqlDBConnObj.fetchRows);
            end
        end
        
        function appendBuiltinData(obj, target, bData)
        % Append builtin data to the tables in the database. The builtin
        % data arrives in a structure array:
        % 
        % module  : char
        % location: char
        % builtins: struct array
        %      symbol   : char
        %      type     : int
        %      signature: char
        %      location : char

            % Handle the empty case
            if isempty(bData), return, end
        
            % Writing to the database is expensive, so first determine
            % which (if any) builtin data is already present in the
            % database. Only merge in the data that's new. Applications
            % that need to completely rewrite the builtin data should call
            % clearBuiltinData before calling appendBuiltinData.
                       
            knownModules = obj.getBuiltinModuleInfo;
            inputModules = { bData.location };
    
            % Subtract knownModules from inputModules; this leaves the set
            % of modules not yet in the database.
            newModules = setdiff(inputModules, knownModules);
            
            % Filter the input list so that it contains only the new
            % modules.
            if ~isempty(newModules)
                keep = cellfun(@(nMod)find(strcmp(nMod, inputModules)), ...
                            newModules);
                bData = bData(keep);
            else
                bData = [];
            end
            
            % Insert Modules and select their IDs
            numMod = numel(bData);
            modID = zeros(1,numMod);

            obj.SqlDBConnObj.beginTransaction('appendBuiltinData');

            for k=1:numMod
                % Minimize indexing
                mData = bData(k);

                obj.SqlDBConnObj.doSql([...
                    'INSERT OR IGNORE INTO Builtin_Module (Name, Location) '...
                    'VALUES (''' mData.module, ''',''' ...
                                 mData.location ''')']);
                obj.SqlDBConnObj.doSql([...
                    'SELECT ID FROM Builtin_Module ' ...
                    'WHERE Name = ''' mData.module '''']);
                modID(k) = obj.SqlDBConnObj.fetchRow;
                modStr = sprintf('%d',modID(k));

                % Taking common operations out of the loop
                symbolInsertPrefix = ...
                  'INSERT INTO Builtin_Symbol (Symbol,Type,Module) VALUES (''';

                % Otherwise, MATLAB calls numel each time, which can be
                % needlessly slow.
                numBuiltin = numel(mData.builtins);
                for n=1:numBuiltin

                    % Minimize indexing
                    b = mData.builtins(n);
                    
                    % Insert Signature and retrieve ID
                    sID = [];
                    if ~isempty(b.signature)
                        sql = [ ...
                            'INSERT OR IGNORE INTO Signature (Signature)' ...
                            'VALUES (''' b.signature ''')'];

                        obj.SqlDBConnObj.doSql(sql);

                        obj.SqlDBConnObj.doSql([ ...
                            'SELECT ID FROM Signature ' ...
                            'WHERE Signature = ''' ...
                            b.signature '''']);
                        sID = obj.SqlDBConnObj.fetchRow;
                    end

                    % Insert Path_Item and retrieve ID
                    pID = [];
                    if ~isempty(b.location)

                        selectSql = [...
                            'SELECT ID FROM Path_Item ' ...
                            'WHERE Path_Item.Location = ''' ...
                            b.location ''''];

                        obj.SqlDBConnObj.doSql(selectSql);
                        pID = obj.SqlDBConnObj.fetchRow;

                        if isempty(pID)
                            obj.SqlDBConnObj.doSql([ ...
                                'INSERT INTO Path_Item (Location) ' ...
                                'VALUES (''' ...
                                b.location ''')']);

                            obj.SqlDBConnObj.doSql(selectSql);
                            pID = obj.SqlDBConnObj.fetchRow;
                        end
                    end

                    % Insert Builtin and retrieve ID
                    tStr = sprintf('%d',b.type);
                    sql = [ symbolInsertPrefix b.symbol, ''',' ...
                            tStr ',' modStr ')'];
                    obj.SqlDBConnObj.doSql(sql);

                    % Can't SELECT by Module,Type,Symbol because that might 
                    % not be unique.
                    obj.SqlDBConnObj.doSql('SELECT last_insert_rowid()');
                    bID = obj.SqlDBConnObj.fetchRow;
                    bIdStr = sprintf('%d',bID);

                    % Bind Builtin to Path_Item (optional)
                    if ~isempty(pID)
                        obj.SqlDBConnObj.doSql([ ...
                            'INSERT INTO Builtin_Path (Builtin,Path) ' ...
                            'VALUES (' bIdStr ',' sprintf('%d',pID) ')']);
                    end

                    % Bind Builtin to Signature (optional)
                    if ~isempty(sID)
                        obj.SqlDBConnObj.doSql([ ...
                       'INSERT INTO Builtin_Signature (Builtin,Signature) ' ...
                       'VALUES (' bIdStr ',' sprintf('%d',sID) ')']);
                    end
                end
            end
            obj.SqlDBConnObj.commitTransaction('appendBuiltinData');
        end

        function [componentID, serviceID] = sharedLicenseEntitlements(obj, part)
        % Do any of the given parts enable a shared license?
        % Return the IDs of those components which the parts enable, and
        % the IDs of the services enabled within those components.
            
            componentID = int64([]);
            serviceID = int64([]);
            if isempty(part), return; end
            
            % Must remove root of MathWorks functions or paths won't match.
            % Database stores root-unbound paths.
            part = normalizeFiles(obj,part);

            % SQLite has a 1000-operator limit (well, technically, the
            % expression tree can't be deeper than 1000 levels), so limit
            % query length.
            maxFiles = 200;
            partLen = numel(part);
            if iscell(part)
                startRange = 1; endRange = min(partLen,maxFiles);
                while startRange < partLen
                    subList = part(startRange:endRange);
                    [cList, sList] = querySharedLicenseComponents(subList, ...
                                                         obj.SqlDBConnObj);

                    componentID = [componentID cList];   %#ok can't prealloc
                    serviceID = [serviceID sList];

                    % Move the range end points
                    startRange = endRange + 1;
                    endRange = min(endRange + maxFiles, partLen);
                end
            else
                [componentID, serviceID] = querySharedLicenseComponents(...
                                   part, obj.SqlDBConnObj);
            end

            componentID = unique(componentID, 'stable');

            function [componentList, serviceList] = ...
                    querySharedLicenseComponents(partList, db)
                % Construct an OR-list (a disjunction) of part path names.
                if iscell(partList)
                    filePathPredicate = ['File.Path =''' partList{1} ''''];
                    if numel(partList) > 1
                        filePathPredicate = ['(' filePathPredicate ...
                       sprintf(' OR File.Path=''%s''', partList{2:end}) ')' ];
                    end
                else
                    filePathPredicate = ['File.Path = ''' partList '''' ];
                end

                % TODO: Unify these two queries. This is inefficient.

                % SQL query to determine which of the input parts are
                % authorized client functions.
                q = [...
'SELECT File.ID FROM Authorized_Client_Functions,File ' ...
'WHERE ' filePathPredicate ' ' ...
'AND Authorized_Client_Functions.File = File.ID'];
                db.doSql(q);
                result = db.fetchRows;
                serviceList = cellfun(@(r)r{1}, result);
                    
                % SQL query to extract IDs of all components
                % which share functions with any authorized functions in the 
                % input list. (That's a mouthful.)

                q = [...
  'SELECT DISTINCT Component_License.Component ' ...
  'FROM File,Shared_Functions,Shared_License_Client,License,' ...
  '     Shared_License_Provider,Authorized_Client_Functions, ' ...
  '     Component_License ' ...
  'WHERE ' filePathPredicate ' ' ...
  'AND Authorized_Client_Functions.File = File.ID ' ...
  'AND Shared_Functions.Client = Authorized_Client_Functions.Client ' ...
  'AND Shared_License_Provider.ID = Shared_Functions.Provider ' ...
  'AND License.ID = Shared_License_Provider.Feature ' ...
  'AND Component_License.License = License.ID' ...
                ];
                db.doSql(q);
                result = db.fetchRows;
                componentList = cellfun(@(r)r{1}, result);
            end
        end

        function mergeLicenseData(obj, otherDD, target)
        % Merge the shared license data from otherDD into this one. 

            % Validate inputs
            narginchk(2,3);
            if ~isa(otherDD,class(obj))
                error(message('MATLAB:Completion:InvalidInputType', ...
                    2, class(otherDD), class(obj)));
            end
            
            % Need another connection to the database for secondary
            % queries.
            tDB = matlab.depfun.internal.database.SqlDbConnector;
            tDB_close = onCleanup(@()tDB.disconnect); 

            function [licenseID, componentID] = mergeLicenseAndComponent(...
                                     db, licenseName, componentName, db_name)
                q = ['SELECT ID FROM License WHERE Name = ''' ...
                     licenseName ''''];
                db.doSql(q);
                licenseID = db.fetchRow; 
                
                % Did not find the license, insert it.
                if isempty(licenseID)
                    q = ['INSERT INTO License (Name) VALUES (''' ...
                         licenseName ''')'];
                    db.doSql(q);
                    db.doSql('SELECT last_insert_rowid()');
                    licenseID = db.fetchRow;
                end
                
                % Get the Component ID -- it must exist already.
                q = ['SELECT ID FROM Component WHERE Name = ''' ...
                     componentName '''' ];
                db.doSql(q);
                componentID = db.fetchRow;
                if isempty(componentID)
                    error(message('MATLAB:Completion:MissingComponent', ...
                        componentName, db_name));
                end
            end

            % Insert Protected_Locations that don't exist yet. May need to
            % insert license as well.)
            q = [ ...
            'SELECT License.Name, Protected_Location.Path, Component.Name ' ...
            'FROM License,Component,Protected_Location ' ...
            'WHERE Protected_Location.Feature = License.ID ' ...
            'AND Protected_Location.Component = Component.ID '];

            otherDD.SqlDBConnObj.doSql(q);

            % First protected location
            [licenseName, protectedLoc, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;

            while ~isempty(protectedLoc)
                % Retrieve / insert license, retrieve component ID
                [licID, protectedCID] = ...
                    mergeLicenseAndComponent(obj.SqlDBConnObj, ...
                                             licenseName, componentName,...
                                             obj.dbName);

                % Does the protected location exist?
                q = ['SELECT Component FROM Protected_Location ' ...
                     'WHERE Feature = ' num2str(licID) ' '...
                     'AND Component = ' num2str(protectedCID) ' '...
                     'AND Path = ''' protectedLoc ''''];
                obj.SqlDBConnObj.doSql(q);
                cID = obj.SqlDBConnObj.fetchRow;
                if isempty(cID)
                    q = ['INSERT INTO Protected_Location ' ...
                         '(Feature, Path, Component) VALUES (' ...
                         num2str(licID), ', ''' protectedLoc ''', ' ...
                         num2str(protectedCID) ')'];
                    obj.SqlDBConnObj.doSql(q);
                end
                
                % Next protected location
                [licenseName, protectedLoc, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;
            end

            % Shared_License_Provider -- get ID, license name,
            % provider location and component name.
            q = [...
                'SELECT Shared_License_Provider.ID,License.Name, ' ...
                '       Shared_License_Provider.Path,Component.Name ' ...
                'FROM Shared_License_Provider,License,Component ' ...
                'WHERE License.ID = Shared_License_Provider.Feature ' ...
                'AND Component.ID = Shared_License_Provider.Component'];
            otherDD.SqlDBConnObj.doSql(q);
            tDB.connect(otherDD.dbName);

            % Insert Shared_License_Providers that don't exist yet (may
            % also need to insert Component and License)
            providerMap = containers.Map('KeyType', 'int32', ...
                                         'ValueType', 'int32');
            [providerID, licenseName, providerPth, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(providerID)
                
                [licID, providerCID] = ...
                    mergeLicenseAndComponent(obj.SqlDBConnObj, ...
                                             licenseName, componentName,...
                                             obj.dbName);

                % Look for the provider
                q = ['SELECT ID FROM Shared_License_Provider ' ...
                     'WHERE Feature = ' num2str(licID) ' '...
                     'AND Component = ' num2str(providerCID) ' ' ...
                     'AND Path = ''' providerPth ''''];
                obj.SqlDBConnObj.doSql(q);
                pID = obj.SqlDBConnObj.fetchRow;
                if isempty(pID)
                    q = ['INSERT INTO Shared_License_Provider ' ...
                         '(Feature, Path, Component) VALUES (' ...
                         num2str(licID), ', ''' providerPth ''', ' ...
                         num2str(providerCID) ')'];
                    obj.SqlDBConnObj.doSql(q);
                    obj.SqlDBConnObj.doSql('SELECT last_insert_rowid()');
                    pID = obj.SqlDBConnObj.fetchRow;                    
                end
                providerMap(providerID) = pID;
                
                % Get the next provider              
                [providerID, licenseName, providerPth, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;
            end
            
            clear tDB_close
            
            % Shared_License_Client
            q = [...
                'SELECT Shared_License_Client.ID,'...
                '       Shared_License_Client.Name, ' ...
                '       Shared_License_Client.Path,Component.Name ' ...
                'FROM Shared_License_Client,Component ' ...
                'WHERE Component.ID = Shared_License_Client.Component'];
            otherDD.SqlDBConnObj.doSql(q);
           
            % Insert Shared_License_Clients that don't exist yet 
            clientMap = containers.Map('KeyType', 'int32', ...
                                         'ValueType', 'int32');
            [clientID, clientName, clientPth, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;
            
            while ~isempty(clientID)
                
                % Get the Component ID
                q = ['SELECT ID FROM Component WHERE Name = ''' ...
                     componentName '''' ];
                obj.SqlDBConnObj.doSql(q);
                clientCID = obj.SqlDBConnObj.fetchRow;
                if isempty(clientCID)
                    error(message('MATLAB:Completion:MissingComponent', ...
                        obj.dbName, componentName));
                end
                
                % Look for the Shared_License_Client
                q = ['SELECT ID FROM Shared_License_Client ' ...
                     'WHERE Name = ''' clientName ''' ' ...
                     'AND Path = ''' clientPth ''' ' ...
                     'AND Component = ' num2str(clientCID) ];
                obj.SqlDBConnObj.doSql(q);
                cID = obj.SqlDBConnObj.fetchRow;
                if isempty(cID)
                    q = ['INSERT INTO Shared_License_Client ' ...
                         '(Name, Path, Component) VALUES (''' ...
                         clientName ''', ''' clientPth ''', ' ...
                         num2str(clientCID) ')'];
                    obj.SqlDBConnObj.doSql(q);                   
                    obj.SqlDBConnObj.doSql('SELECT last_insert_rowid()');
                    cID = obj.SqlDBConnObj.fetchRow;
                end
                clientMap(clientID) = cID;
                [clientID, clientName, clientPth, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;                
            end
            
            % Authorized_Client_Functions
            q = ['SELECT File.Path,Authorized_Client_Functions.Client ' ...
                 'FROM File,Authorized_Client_Functions ' ...
                 'WHERE File.ID = Authorized_Client_Functions.File'];
            otherDD.SqlDBConnObj.doSql(q);
            
            [file, client] = otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(file)
                q = ['SELECT ID FROM File WHERE Path = ''' file ''''];
                obj.SqlDBConnObj.doSql(q);
                fileID = obj.SqlDBConnObj.fetchRow;
                
                if isempty(fileID)
                    error(message('MATLAB:Completion:MissingFile', ...
                        file, obj.dbName));
                end
                
                if ~isKey(clientMap, client)
                    error(message(...
                        'MATLAB:Completion:InternalBadSharedLicenseClientID',...
                         client));
                end
                
                q = ['INSERT INTO Authorized_Client_Functions ' ...
                     '(File, Client) VALUES (' num2str(fileID) ',' ...
                     num2str(clientMap(client)) ')'];
                obj.SqlDBConnObj.doSql(q);
                
                [file, client] = otherDD.SqlDBConnObj.fetchRow;                
            end
            
            % Shared_Functions
            q = ['SELECT File.Path,Shared_Functions.Client,' ...
                 '       Shared_Functions.Provider ' ...
                 'FROM File,Shared_Functions ' ...
                 'WHERE File.ID = Shared_Functions.File'];
            otherDD.SqlDBConnObj.doSql(q);
            
            [file, client, provider] = otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(file)
                q = ['SELECT ID FROM File WHERE Path = ''' file ''''];
                obj.SqlDBConnObj.doSql(q);
                fileID = obj.SqlDBConnObj.fetchRow;
                
                if isempty(fileID)
                    error(message('MATLAB:Completion:MissingFile', ...
                        file, obj.dbName));
                end
                
                if ~isKey(clientMap, client)
                    error(message(...
                        'MATLAB:Completion:InternalBadSharedLicenseClientID',...
                         client));
                end
                
                if ~isKey(providerMap, provider)
                    error(message(...
                        'MATLAB:Completion:InternalBadSharedLicenseProviderID',...
                         client));
                end
                
                q = ['INSERT INTO Shared_Functions (File,Client,Provider) ' ...
                     'VALUES (' num2str(fileID) ',' ...
                     num2str(clientMap(client)) ',' ...
                     num2str(providerMap(provider)) ')'];
                obj.SqlDBConnObj.doSql(q);               
                
                [file, client, provider] = otherDD.SqlDBConnObj.fetchRow;
                
            end
        end

        function mergeBuiltinData(obj, otherDD, target)
        % Merge the builtin data from another database into this one. Since
        % this can be an expensive operation, skip duplicate data -- don't
        % even retrieve it from the source database.
        
            otherModules = otherDD.getBuiltinModuleInfo;
            myModules = obj.getBuiltinModuleInfo;
            newModules = setdiff(otherModules, myModules);
        
            % Only do actual work
            if ~isempty(newModules)
                bData = otherDD.getBuiltinData(target, newModules);
                obj.appendBuiltinData(target, bData);
            end
        end
        
        function mergeComponentBuiltinModuleTable(obj, otherDD)
        % Merge the Component_Builtin_Module tables in obj and otherDD,
        % given the component name of otherDD is cname.
            
            % Find the component ID of the source database
            [~, cIdx] = otherDD.getComponentMembership();
            cIdx = unique(cIdx);

            if ~isempty(cIdx)
                if ~isscalar(cIdx)
                    error(['Detected multiple components. ' ...
                       'All the files in the Component_Membership table ' ...
                       'should belong to the same component in individual ' ...
                       'database.']);
                end
        
                % Find built-ins registered by component cname
                builtinLoc = otherDD.getBuiltinModuleInfo(cIdx);

                if ~isempty(builtinLoc)
                    % Find the component location in the source database
                    cptInfo = otherDD.getComponentInfo(cIdx);
                    if length(cptInfo) ~= 1
                        error(['Component ID ' cIdx ' should be mapped to' ...
                               'one and only one component.']);
                    end
                    
                    % Find the new component ID in the consolidated database
                    obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT ID FROM Component ' ...
                             'WHERE Location = ''%s'';'], cptInfo.location));
                    componentID = obj.SqlDBConnObj.fetchRow();
                    if isempty(componentID)
                        error(['Component ' cptInfo.name ' is not on record.']);
                    end

                    for k = 1:numel(builtinLoc)
                        % Find the new module ID in the consolidated database
                        obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT ID FROM Builtin_Module ' ...
                             'WHERE Location = ''%s'';'], builtinLoc{k}));
                        builtinModuleID = obj.SqlDBConnObj.fetchRow();
                        if isempty(componentID)
                            error(['Builtin module ' builtinLoc{k} ...
                                   ' is not on record.']);
                        end

                        % Add new component builtin_module pair to 
                        % the consolidated database.
                        obj.SqlDBConnObj.doSql(sprintf( ...
                        ['INSERT INTO Component_Builtin_Module (Component, Module) ' ... 
                         'SELECT %d, %d ' ...
                         'WHERE NOT EXISTS '...
                         '    (SELECT 1 FROM Component_Builtin_Module ' ...
                         '     WHERE Component = %d AND Module = %d);'], ...
                        componentID, builtinModuleID, componentID, builtinModuleID));
                    end
                end
            end
        end
        
        function tbl = getBuiltinTable(obj, srchPth, target, type)
        % Return a table mapping each builtin symbol name to its location.
        % Manage duplicates by choosing the first that appears on the path.
        
            % Target and Type are optional.
            if nargin < 3, target = ''; end
            if nargin < 4, type = ''; end
            
            requireTable(obj, 'Builtin_Symbol');
        
            % Select all the builtin paths of the given type.
            sql = [...
                'SELECT Builtin_Symbol.ID,Path_Item.Location ' ...
                'FROM Builtin_Symbol,Path_Item,Builtin_Path ' ...
                'WHERE Builtin_Path.Builtin = Builtin_Symbol.ID ' ...
                'AND Builtin_Path.Path = Path_Item.ID' ];
            if ~isempty(type)
                sql = [sql, ' AND Builtin_Symbol.Type = ' sprintf('%d',type)];
            end
            obj.SqlDBConnObj.doSql(sql);
   
            % Stuff the locations into a hash indexed by symbol ID.
            locHash = containers.Map('KeyType','int64','ValueType','char');
                        
            % Returns a cell-array of cell-array pairs, each pair
            % representing a row in the result set: { id, location }.
            id_loc_list = obj.SqlDBConnObj.fetchRows();
            numPth = numel(id_loc_list);
            pth = cell(numPth,1);
            id1 = int64(zeros(numPth,1));
            for k=1:numPth
                id1(k) = id_loc_list{k}{1};
                pth{k} = id_loc_list{k}{2};
            end
            pth = strrep(pth,'$MATLAB',matlabroot);
            pth = strrep(pth,'/',filesep); % Return platform-specific
            
            for k=1:numPth
                 locHash(id1(k)) = pth{k};
            end
            
            % Select all the builtin symbols and their IDs and Types
            obj.SqlDBConnObj.doSql('SELECT ID,Type,Symbol FROM Builtin_Symbol');
            
            % Create the output table
            tbl = containers.Map;
            
            % Function used to search the path
            function pos = pathPosition(srchPth, item)
                pos = [];
                if ~isempty(item)
                    found = strcmp(srchPth, item);
                    if ~isempty(found)
                        pos = find(found);
                        if numel(pos) > 1, pos = pos(1); end
                    end
                end
            end
            
            % Push the selected data into the output table, using the
            % symbol IDs to bind the path and symbol data together.
            id_type_symbol = obj.SqlDBConnObj.fetchRows();
            numSym = numel(id_type_symbol);
            for k=1:numSym
                % Extract the column values from row K
                id2 = id_type_symbol{k}{1};
                type = id_type_symbol{k}{2};
                symbol = id_type_symbol{k}{3};
                
                % Either this symbol has a location or not. If it does,
                % retrieve the location and normalize to MATLAB root.
                loc = '';
                if isKey(locHash, id2)
                    loc = locHash(id2);
                end
                
                % Duplicate symbol?
                if isKey(tbl, symbol)
                   % Choose the builtin with a location, if possible.
                   % (Always write over empty locations.)
                   if isempty(tbl(symbol))
                       symData.loc = loc;
                       symData.type = type;
                       tbl(symbol) = symData; 
                   else
                        % Both have a location -- choose the location 
                        % that's first on the path.
                        idxCur = pathPosition(srchPth, tbl(symbol).loc);
                        idxNew = pathPosition(srchPth, loc);
                    
                        % If current location is not on the path, or current
                        % location occurs AFTER new location on the path,
                        % replace the current location with the new one.
                        if isempty(idxCur) || (~isempty(idxNew) && ...
                                               idxNew < idxCur)
                            symData = tbl(symbol);
                            symData.loc = loc;
                            symData.type = type;
                            tbl(symbol) = symData;
                        end
                   end
                else
                    % New symbol. Add it to the table.
                     symData.loc = loc;
                     symData.type = type;
                     tbl(symbol) = symData;
                end
            end
        end
		
        function fileList = getExclusion(obj, target)
        % Read the exclusion_list for Target
        % straight forward read from the exclusion_list matched with the target
            fileList = {};
            obj.SqlDBConnObj.doSql('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''Exclusion_List'';');
            if(strcmp(obj.SqlDBConnObj.fetchRow(),'Exclusion_List'))        
                if ~ischar(target)
                    % convert matlab.depfun.internal.Target to string
                    target = matlab.depfun.internal.Target.str(target);
                end
                obj.SqlDBConnObj.doSql(sprintf(...
                    'SELECT ID FROM Target WHERE Name = ''%s'';', target));
                targetID = obj.fetchNonEmptyRow();
        
                obj.SqlDBConnObj.doSql(sprintf([ ...
                    'SELECT Exclude_File.Path ' ...
                    'FROM Exclusion_List, Exclude_File ' ...
                    'WHERE Exclusion_List.File = Exclude_File.ID ' ...
                    'AND Exclusion_List.Target = %d;'], targetID));
                fileList = decell(obj.SqlDBConnObj.fetchRows());
            end
        end
        
        function recordInclusion(obj, target, component, file)
        % save in exclusion_list based on 'target' for 'file'
            
            related_tables = {'Inclusion_List', 'Include_File'};
            cellfun(@(t)obj.clearTable(t), related_tables);
            
            appendInclusion(obj, target, component, file);
        end
		
        function appendInclusion(obj, target, component, file)
        % save in Inclusion_List based on 'target' for 'file'
            
            if ~ischar(target)
                % convert matlab.depfun.internal.Target to string                
                target = matlab.depfun.internal.Target.str(target);
            end
            
            obj.SqlDBConnObj.doSql(sprintf('SELECT ID FROM Target WHERE Name = ''%s'';', target));
            targetID = obj.fetchNonEmptyRow();
            
            if ischar(component)
                componentID = getComponentID(obj, component);
            elseif isnumeric(component)
                componentID = component;
            end
            
            % Note that some files are required by more than one component                   
            file = normalizeFiles(obj, file);
            num_file = numel(file);
            for i = 1:num_file
                obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Include_File where Path = ''%s'';', file{i}));
                fileID = obj.SqlDBConnObj.fetchRow();
                
                if isempty(fileID)
                    obj.SqlDBConnObj.doSql(sprintf('INSERT INTO Include_File (Path) VALUES (''%s'');', file{i}));
                    
                    obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Include_File where Path = ''%s'';', file{i}));
                    fileID = obj.SqlDBConnObj.fetchRow();
                end
                
                obj.SqlDBConnObj.doSql(sprintf(...
                    'INSERT INTO Inclusion_List (Component, Target, File) VALUES (%d, %d, %d);', ...
                    componentID, targetID, fileID));
            end
        end
        
        function fileList = getInclusion(obj, target, component)
        % Read the Inclusion_List for the given component and target
        % straight forward read from the Inclusion_List 
            fileList = {};
            obj.SqlDBConnObj.doSql('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''Inclusion_List'';');
            if(strcmp(obj.SqlDBConnObj.fetchRow(),'Inclusion_List'))        
                if ~ischar(target)
                    % convert matlab.depfun.internal.Target to string
                    target = matlab.depfun.internal.Target.str(target);
                end
                obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Target where Name = ''%s'';', target));
                targetID = obj.SqlDBConnObj.fetchRow();
                
                if ischar(component)
                    componentID = getComponentID(obj, component);
                elseif isnumeric(component)
                    componentID = component;
                end
                
                if ~isempty(componentID) && ~isempty(targetID)
                    obj.SqlDBConnObj.doSql(sprintf([ ...
                        'SELECT Include_File.Path ' ...
                        'FROM Inclusion_List, Include_File ' ...
                        'WHERE Inclusion_List.File = Include_File.ID ' ...
                        'AND Inclusion_List.Target = %d ' ...
                        'AND Inclusion_List.Component = %d;'], targetID, componentID));
                    fileList = decell(obj.SqlDBConnObj.fetchRows());
                end
            end
        end
        
        function componentID = getComponentID(obj, component)
        % If component param is a string, look it up and retrieve corresponding numeric ID; 
        % generate error if not found.
        % If component param is numeric, use it.
        % If component param is some other type, generate error.
            if ischar(component)
                if isempty(component)
                    error(message('MATLAB:Completion:EmptyComponentName'));
                elseif strcmp(component, 'xpc')
                    % TODO: find an alternative to hard-coding this exception to the rule
                    % that the component name is equivalent to the name of the directory
                    % immediately under matlab/toolbox.
                    location = ['$MATLAB/toolbox/rtw/targets/xpc/' component];
                else
                    location = ['$MATLAB/toolbox/' component];
                end
                location = strrep(location, obj.FileSep, '/');
                obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Component where Location = ''%s'';', location));
                % It's okay if the row is empty, so don't call fetchNonEmptyRow().
                componentID = obj.SqlDBConnObj.fetchRow();
            elseif isnumeric(component)
                componentID = component;
            else
                error(message('MATLAB:Completion:InvalidComponentNameType', ...
                              component));
            end
        end
        
        function [componentList, indices] = getComponentList(obj)
            obj.SqlDBConnObj.doSql('SELECT Name from Component');
            componentList = decell(obj.SqlDBConnObj.fetchRows());
            
            obj.SqlDBConnObj.doSql('SELECT ID from Component');
            indices = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
        end
        
        function recordComponentMembership(obj, files, component)
            obj.clearTable('Component_Membership');
            
            obj.appendComponentMembership(files, component);            
        end
        
        function appendComponentMembership(obj, files, component)

            if isempty(obj.ID2Language)
                cacheLanguageTable(obj);
            end

            if ischar(component)
                componentID = double(getComponentID(obj, component));
                if isempty(componentID)
                    error(message('MATLAB:Completion:EmptyComponentID'));
                end
            elseif isnumeric(component)
                componentID = double(component);
            end
            
            if isnumeric(files)
                fileID = files;
                num_files = length(files);
            else
                files = normalizeFiles(obj, files);
                num_files = numel(files);
                fileID = zeros(num_files, 1);

                for k = 1:num_files
                    fileID(k) = obj.findOrInsertFile(files{k});
                end
                fileID(logical(fileID==0)) = [];
                num_files = length(fileID);
            end            
            
            % write to the database at once
            obj.SqlDBConnObj.insert('Component_Membership', ...
                'File', fileID, 'Component', ones(num_files,1).*componentID);
        end
        
        function [fileID, componentID] = getComponentMembership(obj)
            obj.SqlDBConnObj.doSql('SELECT File from Component_Membership');
            fileID = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
            
            obj.SqlDBConnObj.doSql('SELECT Component from Component_Membership');
            componentID = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
        end
        
        function protected = protectedByLicense(obj, parts)
        % Which of the parts are protected by a license? Those in a 
        % protected location!

            % Asking the database is expensive. There aren't that many
            % protected locations, so cache them in a map.
            % Lazy initialization of protected locations cache.
            if isempty(obj.protectedLocations)
                obj.protectedLocations = containers.Map('KeyType', 'char', ...
                                                    'ValueType', 'logical');
                q = 'SELECT Path FROM Protected_Location';
                obj.SqlDBConnObj.doSql(q);
                ploc = cellfun(@(l)l{1},obj.SqlDBConnObj.fetchRows(), ...
                               'UniformOutput',false);
                for k=1:numel(ploc)
                    obj.protectedLocations(ploc{k}) = true;
                end
            end

            % Expand $MATLAB to the actual MATLABROOT
            ixf = matlab.depfun.internal.IxfVariables('/');
            locations = ixf.bind(keys(obj.protectedLocations));
            partLocations = cellfun(@(p)fileparts(p), parts, ...
                                    'UniformOutput', false);
            partLocations = strrep(partLocations,'\','/');
            numLocations = numel(locations);
            
            protected = false(1,numel(partLocations));
            for k=1:numel(parts)
                n = 1;
                found = false;
                while (n <= numLocations && found == false)
                    found = ~isempty(strfind(partLocations{k}, locations{n}));
                    n = n + 1;
                end
                protected(k) = found;
            end
        end

        function [knownParts, componentID, fileID] = ...
                componentMembership(obj, parts)

            % Initialze outputs
            fileID = [];
            componentID = [];
            knownParts = {};
            
            % convert to canonical path relative to matlabroot
            parts = normalizeFiles(obj, parts);
            num_parts = numel(parts);
            if num_parts == 0, return, end

            % Batch queries together, because crossing the MCOS barrier is
            % expensive.
            bucketSize = 64;
            
            % Query structure:
            %
            %  SELECT ifnull(Component_Membership.Component,0)
            %  FROM ( < File Sub-Query > ) AS FID
            %  LEFT JOIN Component_Membership
            %  ON (FID.ID = Component_Membership.File)
            %
            % The File Sub-Query returns a numeric list: File IDs for files 
            % which exist in the database, and zero for those that don't.
            %
            % The LEFT JOIN ensures that the zeros propagate through the 
            % join condition -- files with ID 0 necessarily belong to no
            % component.
            %
            % Note that a file may belong to multiple components.
            
            selectFile = ['SELECT ifnull(max(File.ID),0) AS ID FROM File ' ...
                          'WHERE File.Path = ''%s''' ];
            unionFile = [ ' UNION ALL ' selectFile ];

            start = 1;
            while start <= num_parts
                subQuery = sprintf(selectFile, parts{start});
                start = start + 1;
                if start <= num_parts
                    stop = min(start + bucketSize - 2, num_parts);                
                    subQuery = [ subQuery ... 
                                 sprintf(unionFile, parts{start:stop}) ]; %#ok
                    start = stop + 1;
                end
                query = [ ...
                    'SELECT FID.ID, ifnull(Component_Membership.Component,0) ' ...
                    'FROM ( ' subQuery ' ) AS FID ' ...
                    'LEFT JOIN Component_Membership ' ...
                    'ON (FID.ID = Component_Membership.File)' ];
                obj.SqlDBConnObj.doSql(query);
                cdata = obj.SqlDBConnObj.fetchRows();
                cdata = reshape(cell2mat([cdata{:}])', 2, [])';
                fileID = [fileID ; cdata(:,1)];           %#ok
                componentID = [componentID ; cdata(:,2)]; %#ok
            end
            
            idList = num2str(fileID(1));
            if numel(fileID) > 1
                idList = [idList sprintf(', %d', fileID(2:end))];
            end
            query = ['SELECT ID,Path FROM File WHERE ID IN (' idList ')'];
            obj.SqlDBConnObj.doSql(query);
            files = obj.SqlDBConnObj.fetchRows();
            knownParts = containers.Map();
            
            for n=1:numel(files)
                f = files{n};
                k = obj.denormalizeFiles(f{2});
                knownParts(k) = f{1};
            end        
        end
        
        function componentID = checkComponentMembership(obj, files)
            [~,cID,~] = componentMembership(obj,files);
            % Output: convert cell array contents to doubles; change all
            % zeros to empty.
            num_files = numel(files);
            componentID = cell(num_files,1);
            for k=1:numel(files)
                componentID{k} = double(cID(k));
                if componentID{k} == 0
                    componentID{k} = [];
                end
            end            
        end
          
        function [componentID, moduleID] = ...
                checkBuiltinComponentMembership(obj, bltins)
        % Find the owning components and modules for given built-in symbols
        
            if ischar(bltins)
                bltins = {bltins};
 
            end
            num_bltins = numel(bltins);
            
            componentID = cell(num_bltins, 1);
            moduleID = cell(num_bltins, 1);
            for k = 1:num_bltins
                obj.SqlDBConnObj.doSql(sprintf([ ...
                    'SELECT Builtin_Module.ID ' ...
                    'FROM Builtin_Symbol, Builtin_Module ' ...
                    'WHERE Builtin_Symbol.Symbol = ''%s'' ' ...
                    'AND Builtin_Symbol.Module = Builtin_Module.ID;'], ...
                    bltins{k}));
                tmp = double(cell2mat(decell(obj.SqlDBConnObj.fetchRows())));
                tmp = unique(tmp);                
                
                if ~isempty(tmp)
                    moduleID{k} = tmp(1);
                    
                    obj.SqlDBConnObj.doSql(sprintf([ ...
                        'SELECT Component ' ...
                        'FROM Component_Builtin_Module ' ...
                        'WHERE Component_Builtin_Module.Module = %d;'], ...
                        moduleID{k}));
                    componentID{k} = ...
                        double(cell2mat(decell(obj.SqlDBConnObj.fetchRows())));
                end
            end 
        end           

        function licenseInfo = getLicenseInfo(obj, componentID)
        % Map component IDs to license names, using the database.
        % The names appear in the output licenseInfo structure in the same
        % order as the component IDs in the input vector. The structure
        % has two fields: name (a string) and component (an integer ID).
        %
        % The componentID list must be a sorted set (the output, for example,
        % of UNIQUE). Note that componentID zero maps to license name ''.
            
            licenseInfo = struct();
            if numel(componentID) < 1, return; end

            if ~issorted(componentID)
                error(message(...
                    'MATLAB:Completion:InternalUnsortedComponentID'));
            end

            cIDStr = num2str(componentID(1));
            if numel(componentID) > 1
                cIDStr = [cIDStr sprintf(', %d', componentID(2:end))];
            end

            % May return more licenses than components, since a component
            % may be enabled by more than one license (all components with
            % shared licenses are enabled by at least two licenses).
            query = [ ...
              'SELECT Component_License.Component,License.name ' ...
              'FROM License,Component_License ' ...
              'WHERE License.ID = Component_License.License ' ...
              'AND Component_License.Component IN (' cIDStr ') ' ...
              'ORDER BY Component_License.Component'];

            obj.SqlDBConnObj.doSql(query);
            info = obj.SqlDBConnObj.fetchRows();

            licenseInfo = cellfun(...
                @(r)struct('name',r{2}, 'component', r{1}), info);

            if componentID(1) == 0
                z.name = '';
                z.component = 0;
                if isempty(licenseInfo) || licenseInfo(1).component ~= 0
                    licenseInfo = [z licenseInfo];
                else
                    licenseInfo(1) = z;
                end
            end
        end

        function componentInfo = getComponentInfo(obj, componentID, fields)
            if nargin < 3
                fields = {'name', 'location', 'version', 'release'};
            end

            % Retrieve component information from the database, i.e.,
            % name, location, version, release
            num_component = length(componentID);
            % pre-allocation
            for k=1:numel(fields)
                componentInfo(num_component).(fields{k}) = '';   %#ok
            end

            fStr = fields{1};
            if numel(fields) > 1
                fStr = [fStr sprintf(', %s', fields{2:end})];
            end

            query = sprintf('SELECT %s FROM Component WHERE ID = %%d', ...
                            fStr);

            for k = 1:num_component
                q = sprintf(query, componentID(k));
                obj.SqlDBConnObj.doSql(q);
                tmp = obj.SqlDBConnObj.fetchRows();
                if ~isempty(tmp)
                    tmp = tmp{1};
                    for n=1:numel(fields)
                        componentInfo(k).(fields{n}) = tmp{n};  %#ok
                    end
                end
            end
        end

        function reclaimEmptySpace(obj)
        % Minimize the size of the database by rebuilding it. An expensive
        % operation.
            obj.SqlDBConnObj.doSql('VACUUM');   
        end
        
        function recordPrincipals(obj, proxy, principal)
        % Populate the Proxy_Principal table.
        % proxy contains the names or file IDs of proxies.
        % principal contains names or file IDs of principals.
        
            % Find file ID for the proxy
            if isnumeric(proxy)
                proxyID = proxy;
            elseif ischar(proxy)
                proxy_normalized = normalizeFiles(proxy);
                proxyID = cell2mat(cellfun(@(p)obj.findOrInsertFile(p), ...
                          proxy_normalized, 'UniformOutput', false));
            else
                error(message('MATLAB:DependencyDepot:InvalidInputType', ...
                              1, class(proxy), 'a string or a number'));
            end

            % Find file ID for principals
            if isnumeric(principal)
                principalID = principal;
            elseif ischar(principal)
                principal_normalized = normalizeFiles(principal);
                principalID = cell2mat(cellfun(@(p)obj.findOrInsertFile(p), ...
                              principal_normalized, 'UniformOutput', false));
            else
                error(message('MATLAB:DependencyDepot:InvalidInputType', ...
                              1, class(principal), 'cell or numeric array'));
            end

            % Record the proxy-principal pairs
            obj.SqlDBConnObj.insert('Proxy_Principal', ...
                             'Proxy', proxyID, 'Principal', principalID);
        end
        
        function result = getProxyPrincipal(obj)
            obj.SqlDBConnObj.doSql('SELECT Proxy FROM Proxy_Principal;');
            proxy = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
            
            obj.SqlDBConnObj.doSql('SELECT Principal FROM Proxy_Principal;');
            principal = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
            
            result = [proxy principal];
        end
        
        function principalID = retrievePrincipals(obj, proxyID)
        % Retrieve file ID of principals, given the file ID of a proxy.
            if isnumeric(proxyID) && length(proxyID)==1
                query_cmd = sprintf(['SELECT Principal ' ...
                                     'FROM Proxy_Principal ' ...
                                     'WHERE Proxy = %d;'], proxyID);
                obj.SqlDBConnObj.doSql(query_cmd);
                principalID = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
            else
                error(message('MATLAB:DependencyDepot:InvalidInputType', ...
                              1, class(proxy), 'a number'));
            end
        end
    end

    methods(Access = private)

        function id = lookupPathID(obj, files)
            files = normalizeFiles(obj, files);
            fileSelector = sprintf('Path = ''%s''', files{1});
            if numel(files) > 1
                fileSelector = [fileSelector ' ' ...
                                sprintf(' OR Path = ''%s''', files{:})];
            end

            obj.SqlDBConnObj.doSql(...
                sprintf('SELECT ID FROM File WHERE %s;', fileSelector));
            id = obj.SqlDBConnObj.fetchRow();
        end

        function [lang, type, sym] = getFileData(obj, pth)
            sym = '';
            [lang, type] = obj.fileClassifier.classify(pth);
            if strcmp(lang,'MATLAB')
                [~,sym] = fileparts(pth);
            end
            if isKey(obj.Language2ID, lang)
                lang = obj.Language2ID(lang);
            else
                error(message('MATLAB:Completion:InternalBadLanguage', ...
                              lang, obj.dbName));
            end
        end

        function id = findOrInsertFile(obj, pth)
            select = sprintf('SELECT ID from File where Path = ''%s'';', pth);
            obj.SqlDBConnObj.doSql(select);
            id = obj.SqlDBConnObj.fetchRow();
            if isempty(id)
                [lang, type, sym] = getFileData(obj, pth);
                q = sprintf(...
                    ['INSERT INTO File (Path, Language, Type, Symbol) ' ...
                     'VALUES (''%s'', %d, %d, ''%s'')'], pth, lang, ...
                    int32(type), sym);
                obj.SqlDBConnObj.doSql(q);
                obj.SqlDBConnObj.doSql(select);
                id = obj.SqlDBConnObj.fetchRow();
                if isempty(id)
                    op = sprintf('INSERT File: ''%s''', pth);
                    error(message('MATLAB:Completion:InternalDBFailure', ...
                                  op, obj.dbName));
                end
            end
        end

        function requireTable(obj, tableName)
        % Calling this function asserts that table tableName must exist in
        % the database. If it does not an error is thrown.
            sql = ['SELECT name FROM sqlite_master ' ...
                   'WHERE type=''table'' AND name=''' tableName ''''];
            obj.SqlDBConnObj.doSql(sql);
            name = obj.SqlDBConnObj.fetchRow;
            if isempty(name)
                error(message('MATLAB:Completion:MissingDatabaseTable', ...
                              obj.dbName, name));
            end
        end

        function clearTable(obj, table)
        % Clear an existing table. For performance, drop and recreate
        % the table.
            obj.destroyTable(table);
            obj.createTable(table);
        end
        
        function createTable(obj, table)
        % Create a table, using the column definitions in the tableData
        % map.
            if isKey(obj.tableData, table)
                cols = obj.tableData(table);
                query = ['CREATE TABLE ' table ' ( ' cols{1} ...
                         sprintf(', %s', cols{2:end}) ')'];
                obj.SqlDBConnObj.doSql(query);
            else
                
            end
        end
        
        function clearSharedLicenseTables(obj)
        % Clear the tables containing shared license data
            tables = {'Protected_Location', ...
                      'Shared_License_Client', ...
                      'Authorized_Client_Functions', ...
                      'Shared_Functions', ...
                      'Shared_License_Provider'};
            cellfun(@(t)obj.clearTable(t), tables);
        end

        function clearFileTables(obj)
        % Clear the file table and all the tables that depend on it.
            fileTables = {'File', 'Proxy_Closure', 'Level0_Use_Graph'};
            cellfun(@(t)obj.clearTable(t), fileTables);
        end
        
        function destroyTable(obj, tablename)
        % Destroy an existing table. Don't try to destroy tables that don't
        % exist, since that makes SQLite angry.
            obj.SqlDBConnObj.doSql(['SELECT name FROM sqlite_master WHERE type=''table'' AND name=''' tablename ''';']);
            if(strcmp(obj.SqlDBConnObj.fetchRow(),tablename))
                obj.SqlDBConnObj.doSql(['DROP TABLE ' tablename ';']);
            end
        end
        
        function destroyAllTables(obj)
        % Destory all the tables by applying the destroyTable method to all
        % known tables.
            tables = keys(obj.tableData);
            cellfun(@(t)obj.destroyTable(t), tables);         
        end

        function createTables(obj)
            import matlab.depfun.internal.MatlabType;
            % Create tables
            
            tables = keys(obj.tableData);
            cellfun(@(t)obj.createTable(t), tables);
            
            % Initialize tables
            
            % table Language(id, name).
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''MATLAB'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''CPP'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''Java'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''NET'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''Data'');');

            % table Symbol_Type(id, type)
            % consistent with types defined in matlab.depfun.internal.MatlabType
            function initSymbolType(db,type)
                name = char(type);
                value = int32(type);
                q = sprintf(['INSERT INTO Symbol_Type (Name,Value) ' ...
                             'VALUES (''%s'',%d)'], name, value);
                db.doSql(q);
            end
            
            db = obj.SqlDBConnObj;
            initSymbolType(db,MatlabType.NotYetKnown);
            initSymbolType(db,MatlabType.MCOSClass);
            initSymbolType(db,MatlabType.UDDClass);
            initSymbolType(db,MatlabType.OOPSClass);
            initSymbolType(db,MatlabType.BuiltinClass);
            initSymbolType(db,MatlabType.ClassMethod);
            initSymbolType(db,MatlabType.UDDMethod);
            initSymbolType(db,MatlabType.UDDPackageFunction);
            initSymbolType(db,MatlabType.Function);
            initSymbolType(db,MatlabType.BuiltinFunction);
            initSymbolType(db,MatlabType.BuiltinMethod);
            initSymbolType(db,MatlabType.BuiltinPackage);
            initSymbolType(db,MatlabType.Data);
            initSymbolType(db,MatlabType.Ignorable);
            initSymbolType(db,MatlabType.Extrinsic);
                
            % table Proxy_Type(id, type)
            proxy_type = {...
                'MCOSClass','UDDClass','OOPSClass','BuiltinClass'};
            insert_cmd = ['INSERT INTO Proxy_Type (Type) ' ...
                          '  SELECT Symbol_Type.ID ' ...
                          '  FROM Symbol_Type ' ...
                          '  WHERE Symbol_Type.Name = ''proxy_type'';'];
            cellfun(@(p)obj.SqlDBConnObj.doSql( ...
                    regexprep(insert_cmd, 'proxy_type', p)), proxy_type);
            
            % table Target(id, name) -- same order as numerical values in
            % matlab.depfun.internal.Target.
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''MCR'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''MATLAB'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''PCTWorker'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''All'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''None'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Target (Name) VALUES(''Unknown'');');

        end
        
        function cacheLanguageTable(obj)
            % initialize the map
            obj.Language2ID = containers.Map('KeyType', 'char', ...
                                             'ValueType', 'double');
            obj.ID2Language = containers.Map('KeyType', 'double', ...
                                             'ValueType', 'char');
            
            % load the table into the map
            obj.SqlDBConnObj.doSql('SELECT COUNT(*) from Language;');
            num_lang = obj.SqlDBConnObj.fetchRow();
            for k = 1:num_lang
                obj.SqlDBConnObj.doSql(...
                    sprintf('SELECT Name from Language where ID = %d;', k));
                Language = obj.SqlDBConnObj.fetchRow();
                obj.Language2ID(Language) = k;
                obj.ID2Language(k) = Language;
            end
        end
        
        function recordEdges(obj, graph, table)
            edges = graph.EdgeVectors;
            % convert vertexID to fileID
            clientFID = double(edges(:,1) + 1);
            dependencyFID = double(edges(:,2) + 1);
            
            % insert the data at once
            obj.SqlDBConnObj.insert(table, ...
                'Client', clientFID, 'Dependency', dependencyFID);
        end
        
        function graph = createGraphAndAddEdges(obj, table)
        % create a graph based on the File table
        
            % improvements for performance, g904544
            % (1) cache Language table
            if isempty(obj.ID2Language)
                cacheLanguageTable(obj);
            end
        
            % (2) use bulk select for performance
            obj.SqlDBConnObj.doSql('SELECT ID, Path, Type, Symbol FROM File;');
            files = obj.SqlDBConnObj.fetchRows();
            num_files = numel(files);            
            % preallocation
            fileID = zeros(num_files,1);            
            sym(num_files).symbol = [];
            for i = 1:num_files
                fileID(i) = files{i}{1};
                Path = files{i}{2};
                TypeID = files{i}{3};
                Type = matlab.depfun.internal.MatlabType(TypeID);
                Symbol = files{i}{4};
                
                % create a symbol
                sym(i).symbol = matlab.depfun.internal.MatlabSymbol(Symbol, Type, Path);
            end
            
            % create a new graph
            graph = matlab.internal.container.graph.Graph('Directed', true);
            % add nodes to the graph
            addVertex(graph, sym);
            
            % add edges to the graph based on the specified table            
            obj.SqlDBConnObj.doSql(['SELECT Client, Dependency from ' table ';']);
            edges = obj.SqlDBConnObj.fetchRows();
            num_edges = numel(edges);
            clientFileID = zeros(num_edges,1);
            dependencyFileID = zeros(num_edges,1);
            for i = 1:num_edges
                % read in an edge
                clientFileID(i) = edges{i}{1};
                dependencyFileID(i) = edges{i}{2};
            end
            % convert from fileId to vertexId           
            clientVID = clientFileID - 1;
            dependencyVID = dependencyFileID - 1;
            
            % add the edge to the graph
            addEdge(graph, clientVID, dependencyVID);          
        end
        
        function tf = isfullpath(obj, file)
            % Ugly, but faster than regexp.
            % File is a full path already if:
            %   * It starts with / on any platform.
            %   * On the PC, it starts with / or \
            %   * On the PC, it starts with X:\ or X:/ (where X is any drive)
            tf = (~isempty(file) && ...
                 (file(1) == obj.FileSep || file(1) == '/' || ...
                 (obj.isPC && numel(file) >= 3 && file(2) == ':' && ...
                 (file(3) == obj.FileSep || file(3) == '/'))));
        end
        
        function absolute_path = denormalizeFiles(obj, file)
            if iscell(file)
                absolute_path = cell(1,numel(file));
                for k=1:numel(file)
                    if ~obj.isfullpath(file)
                        absolute_path{k} = [obj.MatlabRoot obj.FileSep file];
                    else
                        absolute_path{k} = file;
                    end
                end
            else
                if ~obj.isfullpath(file)
                    absolute_path = [obj.MatlabRoot obj.FileSep file];
                else
                    absolute_path = file;
                end
            end
            if obj.isPC
                absolute_path = strrep(absolute_path, '/', obj.FileSep);
            end
        end

        function relative_path = normalizeFiles(obj, files)
            if ~iscell(files)
                files = { files };
            end
            
            % matlabroot patterns
            pat = [obj.MatlabRoot obj.FileSep];
            pat1 = regexptranslate('escape', pat);
            pat2 = strrep(pat,obj.FileSep, '/');
            expr = ['(' pat1 '|' pat2 ')'];

            % remove matlabroot
            relative_path = regexprep(files, expr, '');
            % canonical path
            relative_path = strrep(relative_path,obj.FileSep,'/');
        end
    end
end

% local helper function(s)
function output = decell(input)
    rows = numel(input);
    output = cell(rows,1);
    for i = 1:rows
        output{i} = input{i}{1};
    end
end

