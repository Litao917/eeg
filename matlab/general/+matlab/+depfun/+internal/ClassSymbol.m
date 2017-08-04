classdef ClassSymbol < handle

    properties(SetAccess = protected)
    % Public read access
        ClassName               % Fully-qualified class name
        ClassDir                % Class directory
        ConstructorFile         % Full path to constructor 
        ClassType               % Type (UDD, MCOS, etc.) of the class
    end

    properties(Dependent)
        Symbol
        FileList                % The files belonging to the class
        FileCount               % How many files belong to the class
        FileType                % Types of the files (method, etc.)
    end
    
    methods (Static)
        function declareToxic(locations)
            ixf = matlab.depfun.internal.IxfVariables('/');
            locations = strrep(ixf.bind(locations),'/',filesep);
            toxicLocations(locations);
        end
    end
    
    methods (Access = private)
        
        function types = fileTypes(obj, files)
            import matlab.depfun.internal.MatlabType;
            
            fileCount = numel(files);
            types = repmat(MatlabType.NotYetKnown, 1, fileCount);
            for f=1:fileCount
                file = files{f};
                
                if isExecutable(file) && ...
             	   isempty(strfind(file, obj.ConstructorFile))
                    switch obj.ClassType
                        case MatlabType.UDDClass 
                            numAt = numel(find(file == '@'));
                            if numAt == 2
                                types(f) = MatlabType.UDDMethod; 
                            elseif numAt == 1
                                types(f) = MatlabType.UDDPackageFunction;
                            else
                                types(f) = obj.ClassType;
                            end
                        otherwise
                            types(f) = MatlabType.ClassMethod;
                    end
                else
                    % Not ideal, but the enumeration doesn't let us do much
                    % better. TODO: determine if we need to use Data,
                    % Ignorable and Extrinsic here, as appropriate.
                    types(f) = obj.ClassType;
                end
            end
        end
        
    end
    
    methods
        function files = get.FileList(obj)
            import matlab.depfun.internal.MatlabType;
           
            if obj.ClassType == MatlabType.UDDClass
                files = getUDDFiles(obj.ClassName, obj.ClassDir);
            else
                files = getClassFiles(obj.ClassName);
                % Single file MCOS classes may not be found by WHAT.
                if isempty(files)
                    files = { obj.ConstructorFile };
                end
            end
            files = unique(files);
        end
        
        function types = get.FileType(obj)
            import matlab.depfun.internal.MatlabType;

            % All the *.m files on the file list, except for the
            % constructor file (and schema files), are methods of the class.
            files = obj.FileList;
            types = fileTypes(obj, files);   
    
        end
        
        function n = get.FileCount(obj)
            n = numel(obj.FileList);
        end
        
        function sym = get.Symbol(obj)
            sym = matlab.depfun.internal.MatlabSymbol(obj.ClassName, ...
                                                      obj.ClassType);
        end
    end
    
    methods
        function obj = ClassSymbol(qName, whichResult, type)
        % ClassSymbol Constructor for ClassSymbol objects. Initialize
        % methodList, fileList and constructorPath. Input: fully qualified
        % class name and file path used to determine class name.
            import matlab.depfun.internal.MatlabType;
            
            obj.ClassName = qName;
            numInputs = nargin;
            if numInputs < 2 || numInputs > 3
                error(message('MATLAB:Completion:BadInputCount', ...
                              '2 or 3', numInputs, ...
                              'matlab.depfun.internal.ClassSymbol'));
            end
            if numInputs < 3
                type = MatlabType.NotYetKnown;
            end
            
            if ~ischar(whichResult)
                error(message('MATLAB:Completion:InvalidInputType', ...
                    2, class(whichResult), 'string'));
            end
            
            if isempty(whichResult)
                error(message('MATLAB:Completion:InvalidInputType', ...
                    2, 'empty', 'string'));
            end
            
            % Use the whichResult to approximate the class directory.
            classDir = '';
            if numInputs > 1 && ~isempty(whichResult) && ...
                    numel(whichResult) > 0
                sepIdx = strfind(whichResult, filesep);
                if ~isempty(sepIdx)
                    bI = 'built-in (';
                    classDir = whichResult(1:sepIdx(end)-1);
                    if strncmp(bI,classDir,numel(bI))
                        classDir = [classDir ')'];
                    end
                end
            end
            obj.ClassDir = classDir;
            
            [~, obj.ConstructorFile] = className(whichResult);
            if type == MatlabType.NotYetKnown
                obj.ClassType = classType(qName, whichResult);
            else
                obj.ClassType = type;
            end
        end
        
        function [files, types] = classFilesAndTypes(obj)
            files = obj.FileList;
            types = fileTypes(obj, files);            
        end
    end
end

%-------------------------------------------------------------------------
% Class variables
function locations = toxicLocations(locations)
    persistent polluted
    if nargin == 1
        polluted = locations;
    end
    locations = polluted;
end

%-------------------------------------------------------------------------
% Local functions
function files = getUDDFiles(className, uddDir)
% getClassDirFiles Get all the files in the class directory and those in
% the private directory, if the class directory contains a private directory.
% If classDir is empty, return an empty cell array.
%
% classDir may be a cell array of multiple class directories. 
    files = {};

    function fList = getClassFiles(d)
        fList = getDirContents(d);
        fList = fullfile(d, fList);

        % If there is a private folder in the @-directory,
        % add all the files in that private folder.
        [privateFiles, privateDirName] = getPrivateFiles(d);
        privateFiles = strcat(privateDirName,filesep,privateFiles);
        
        fList = [fList; privateFiles];   
        fList = fList';
    end

    if iscell(uddDir)
        for k=1:numel(uddDir)
            files = [files getClassFiles(uddDir{k})]; %#ok
        end
    elseif ~isempty(uddDir) && numel(uddDir) > 0
        files = getClassFiles(uddDir);
    end
    
    % Add constructor, if it exists.
    dotIdx = strfind(className,'.');
    if ~isempty(dotIdx)
        dotIdx = dotIdx(end);
        className = className((dotIdx+1):end);
    end
    constuctorFile = strcat(uddDir, filesep, className, '.m');
    if matlab.depfun.internal.cacheExist(constuctorFile,'file')
        files = [files {constuctorFile}];
    end
end

function files = getClassFiles(className)
    files = {};
    whatName = strrep(className,'.','/');
    whatResult = what(whatName);
    classDirs = strcat({whatResult.path}, filesep);
    
    % Some directories are toxic -- they create a lot of work for no
    % reward. For example, the Symbolic Toolbox extends the @double
    % directory. Yet the Symbolic Toolbox is not deployable. For the MCR
    % target, the Symbolic Toolbox directories are toxic.
    keepOut = toxicLocations;
    for t = 1:numel(keepOut)
        keep = cellfun('isempty', strfind(classDirs, keepOut{t}));
        classDirs = classDirs(keep);
        whatResult = whatResult(keep);
    end
    
    % WHAT may find extraneous directories -- toss them out of the club. A
    % class directory must have at least one @-sign in it.
    keep = ~cellfun('isempty',strfind(classDirs,'@'));
    classDirs = classDirs(keep);
    whatResult = whatResult(keep);

    % Full paths to all files
    for k=1:numel(classDirs)
        wr = whatResult(k);
        dirFiles = [wr.m ; wr.p ; wr.mex];
        if isfield(wr,'mlx'), dirFiles = [dirFiles wr.mlx]; end
        % dirFiles must be a row vector or stcat will fail.
        files = [files{:} strcat(classDirs{k}, dirFiles')];
    
        % Get private files, and prepend <classDir>/private to each.
        fs = filesep;
        pvtFiles = getPrivateFiles(classDirs{k});        
        if ~isempty(pvtFiles)
            pvtDir = fullfile(classDirs{k}, 'private');
            files = [files strcat([pvtDir fs], pvtFiles')];
        end
    end
end