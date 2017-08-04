function w_new = whichNonBuiltin(name, w)
% w_new = whichNonBuiltin(sym, w)
% whichNonBuiltin returns the WHICH result (w_new) of the first non-builtin
% symbol before the built-in symbol (sym) on the MATLAB path.
% The result (w_new) is empty if there is no non-builtin symbol before the built-in
% symbol (sym).
%
% Author: Yufei Shen
% Date: Jun 10th, 2013

w_new = '';

% Database settings
merged_db = fullfile(matlabroot,'toolbox','matlab','general',...
    '+matlab','+depfun','+internal',['requirements_' computer('arch') '_dfdb']);
SqlDBConnObj = matlab.depfun.internal.database.SqlDbConnector;
SqlDBConnObj.connect(merged_db);
disconnectDB = onCleanup(@()SqlDBConnObj.disconnect);

% Find the location of the built-in
pathInfo = regexp(w, '^built-in \((.+?)\)','tokens');
if ~isempty(pathInfo)
    pathInfo = pathInfo{1}{1};
    [builtinDir,~,~] = fileparts(pathInfo);
else
    % Extract path information of the built-in from the database
    SqlDBConnObj.doSql(sprintf(['SELECT Path_Item.Location ' ...
        'from Builtin_Symbol, Builtin_Path, Path_Item ' ...
        'WHERE Builtin_Symbol.Symbol = ''%s'' ' ...
        'AND Builtin_Symbol.ID = Builtin_Path.Builtin ' ...
        'AND Builtin_Path.Path = Path_Item.ID;'], name));
    builtinDir = SqlDBConnObj.fetchRows();
    if ~isempty(builtinDir)
        builtinDir = builtinDir{1}{1};
    end
end

if ~isempty(builtinDir)
    % remove '/+' or '/@' or '/private'
    if ismac
        % Temp directories start with '/private/' on Mac. 
        builtinDir = regexprep(builtinDir, ...
                  '(?!^[/\\]private[/\\].+)[/\\]([@+]|private[/\\]).+','');
    else
        builtinDir = regexprep(builtinDir, '[/\\]([@+]|private[/\\]).+', '');
    end
    
    % replace '$MATLAB' with matlabroot
    builtinDir = strrep(builtinDir, '$MATLAB', matlabroot);
    % normalize
    builtinDir = strrep(builtinDir, '/', filesep);
    
    % preserve the original path
    orgPath = path;

    % find the position of the built-in dir on the MATLAB path
    % STRFIND is 2 to 3 times faster than REGEXP in this case.
    builtinDirPos = strfind(orgPath, builtinDir);
    if ~isempty(builtinDirPos)
        % Remove builtinDir and entries behind it from the MATLAB path
        % If the position of the built-in dir is less than 2, trimmedPath
        % will be empty.
        trimmedPath = orgPath(1:builtinDirPos-2);
        if ispc
            pathItems = strsplit(trimmedPath,';');
        elseif isunix
            pathItems = strsplit(trimmedPath,':');
        end
        % Add pwd to the top of the path
        pathItems = [{pwd} pathItems];

        matlabDir_pat = ['^' regexptranslate('escape', matlabroot)];
        userDirIdx = cellfun('isempty',regexp(pathItems,matlabDir_pat,'ONCE'));
        
        % treat toolbox/compiler/patch as user directory, since files in
        % that directory are not recorded in the database.
        patchDir = fullfile(matlabroot,'toolbox/compiler/patch');
        if exist(patchDir, 'dir') == 7
            compiler_patch_dir_pat = ['^' regexptranslate('escape', patchDir)];
            patchDirIdx = ~cellfun('isempty',regexp(pathItems, ...
                                           compiler_patch_dir_pat,'ONCE'));
            userDirIdx = userDirIdx | patchDirIdx;
        end
        
        % look for the symbol in the database
        SqlDBConnObj.doSql(sprintf('SELECT Path from File WHERE symbol = ''%s''',name));
        fileList = decell(SqlDBConnObj.fetchRows());
        dirList = {};
        if ~isempty(fileList)
            % remove file name
            dirList = cellfun(@(p)regexprep(p,['[/\\]' name '\..*'],''),fileList,'UniformOutput',false);
            % remove +, @, private dirs
            dirList = cellfun(@(p)regexprep(p,'[/\\]([@+]|private[/\\]).+',''),dirList,'UniformOutput',false);
            % normalize path items
            dirList = strrep(dirList,'/',filesep);
            dirList = strcat(matlabroot, filesep, dirList);
            
            % compare dot-qualified name
            qNameList = cellfun(@(p)qualifiedName(p),fileList,'UniformOutput',false);
            qNameIdx = strcmp(qNameList, name);
            for k = 1:numel(fileList)
                if ~qNameIdx(k)
                    dirList{k} = '';
                end
            end
        end

        for k = 1:numel(pathItems)
            if userDirIdx(k)
                % look for the symbol from the user dir
                dirResult = dir([pathItems{k} filesep name '.*']);
                if ~isempty(dirResult)
                    % If there is a non-builtin with the identical name before the
                    % built-in, WHICH can find it. If not, WHICH returns an empty string. 
                    w_new = which(name);
                    break;
                end
            else
                fileIdx = find(strcmp(dirList,pathItems{k}),1,'first');
                if ~isempty(fileIdx)
                    w_new = [matlabroot filesep strrep(fileList{fileIdx},'/',filesep)];
                    break;
                end
            end
        end % end of for loop
    end
end
clear disconnectDB

end

% local helper function(s)
function output = decell(input)
    rows = numel(input);
    output = cell(rows,1);
    for i = 1:rows
        output{i} = input{i}{1};
    end
end