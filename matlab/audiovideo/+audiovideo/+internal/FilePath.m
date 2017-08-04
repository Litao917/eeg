classdef FilePath
    %FilePath Summary of this class goes here
    %   FilePath represents a path to a file and properties
    %   about that path.  FilePath will not error when given filenames
    %   that do not exist, or have paths that are malformed, but will
    %   simply reflect these issues via FilePath's properties.
    %

    % Author: Nick Haddad
    % Copyright 2012-2013 The MathWorks, Inc.

    properties (SetAccess='private')
        Path       % The path to the file as provided by the caller, including the file name
        ParentPath % Path of the files parent directory as provided by the caller
    end

    properties (Dependent, SetAccess='private')
        % absolute path to the file. 
        % Empty ([]) if the file's containing folder does not exist
        % on disk.
        Absolute  
    end
    
    properties (SetAccess='private')
        Extension  % Extension of the file path
    end
    
    properties (Dependent, SetAccess='private')
        Exists    % true if the the file exists, false otherwise.  
        Readable  % true if the file readable, false otherwise.
        Writeable % true if the file is writeable, false otherwise.
    end
    
    
    methods
        function obj = FilePath(filename)
            % Construct a FilePath given FILENAME, an absolute or relative 
            % path to a file.  The file does not have to exist on disk
            % and can include folders that do not exists in the path
            obj.Path = filename;
            
            [obj.ParentPath, ~, obj.Extension] = fileparts(filename);
        end
        
        function exists = get.Exists(obj)
           [exists, info] = fileattrib(obj.Path);
           
           exists = exists && ~info.directory;
        end
        
        function readable = get.Readable(obj)
           if ~obj.Exists
               readable = false;
               return; % file does not exist
           end
           
           % Check if the file has read permissions
           % by opening the file for reading.
           fid = fopen(obj.Path, 'r');
           if (fid ~= -1)
               fclose(fid);
           end;
           
           readable = (fid ~= -1);
        end
        
        function writeable = get.Writeable(obj)
            filename = obj.Absolute;
            if (isempty(obj.Absolute))
                writeable = false;
                return;
            end
            
            % Test that the file can actually be created.
            % Open it in append mode so that any existing file is not
            % destroyed.
            fileExisted = obj.Exists;
            fid = fopen(filename, 'a');
            
            writeable = (fid ~= -1);
            
            if (fid ~= -1)
               fclose(fid);
            end
            
            if (~fileExisted && (fid ~= -1))
                delete(filename);
            end
        end
        
        
        function absolutePath = get.Absolute(obj)
            % Since the file is write-able and currently exists, use
            % fileattrib to convert the filename into a fully qualified
            % absolute path.
            filename = obj.Path;
            if (~obj.Exists)
                % File doesn't yet exist
                % get the fully qualified path
                
                % Many MATLAB functions assume that any slashes in a file name
                % are really the filesep for the current platform.
                filename = regexprep(obj.Path, '[\/\\]', filesep);
                
                [pathstr, baseFile, extProvided ] = fileparts(filename);
                
                % Validate that the directory specified exists.
                if isempty(pathstr)
                    pathstr = pwd;
                end
                
                if ~exist(pathstr, 'dir')
                    absolutePath = [];
                    return;
                end
                
                % Path exists, get its fully qualified path
                [~, pathInfo] = fileattrib(pathstr);
                pathstr = pathInfo.Name;
                
                % rebuild the fully qualified path
                absolutePath = fullfile(pathstr, [baseFile extProvided]);

                absolutePath = mexAVGetAbsolutePath(absolutePath);
            else
                [~, info] = fileattrib(filename);
                absolutePath = info.Name;
            end
        end
        
        function obj = set.Extension(obj,ext)
            obj.Extension = ext;
                   
            % strip any leading '.' separators
            if strncmp(obj.Extension,'.',1)
                obj.Extension = obj.Extension(2:end);
            end
     
        end
    end
    
    
end

