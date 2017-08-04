function [parts, resources, exclusions] = ...
    requirements(files, varargin)
% REQUIREMENTS Analyze files and determine what they require to run.
%
%   [ parts, resources, exclusions ] = 
%               requirements(files [,target] [,'-p', path_limit], 
%                            ['-i', include_path])
%
% FILES: Cell array of files to analyze for dependencies. Specify the file
%        names as relative or absolute path strings findable with WHICH or
%        EXIST. As a special case, a single file may be specified as a 
%        intead of a cell array.
%
% TARGET: The string name of a valid target: MCR, MATLAB, PCTWorker, etc.
%
% PATH_LIMIT: A list of directories from the MATLAB path; limits the 
%             search for the PARTS required by FILES to these directories 
%             and the directories in toolbox/matlab. The PATH_LIMIT
%             directoires must already be on the MATLAB path. They are
%             searched in the order they appear on the MATLAB path rather
%             than the order in which they appear in the PATH_LIMIT list. 
%             Specify directories as full paths or non-ambiguious relative 
%             paths. For example, use 'images' to refer to the Image 
%             Processing Toolbox because matlab/toolbox/images
%             is the root directory for that toolbox. If a sub-directory of 
%             a PATH_LIMIT directory is on the MATLAB path, it is added to 
%             the search path.
%
% INCLUDE_PATH: A list of directories added to the beginning or end of the
%               path. +i adds them to the head of the path, -i to the end.
%               Like PATH_LIMIT, the directory argument must be either a
%               string (a single directory) or a cell array of strings.
%
% -p and -I may appear multiple times in the argument list, in any order,
% but must always appear after the FILES argument, and must be followed by
% a string or cell array of strings.
%
% PARTS: A cell array of the "parts" (files, mostly) required to execute
%        the functions in the input FILES.
%
% RESOURCES: A cell array of the resources (resoures contain parts)
%            required to execute the functions in the input FILES.
%
% EXCLUSIONS: A cell array of parts that FILES requires but the TARGET 
%             forbids. These parts either cannot be shipped to any target
%             or are expected to be present in the specified TARGET
%             environment.

% Valid, if boring, values for all outputs.
parts = {};
resources = {};
exclusions = {};

% Special case error for zero inputs
if nargin == 0
    error(message('MATLAB:Completion:NoFilesToAnalyze'));
end

% Determine target, which we need to know in order to determine the number
% of possible inputs.
if nargin == 1
    target = 'None';
else
    target = varargin{1};
end

% target must be a string
if ~ischar(target)
    error(message('MATLAB:Completion:InvalidInputType', 2, class(target), ...
        'string'));
end

% Convert target input string to Target object and validate.
tgt = matlab.depfun.internal.Target.parse(target);
if (tgt == matlab.depfun.internal.Target.Unknown)
    error(message('MATLAB:Completion:BadTarget', target));
end

% Use the REQUIREMENTS database by default, but allow an environment variable
% to force slower and less accurate dynamic analysis. To skip database
% lookup, set the environment variable REQUIREMENTS_DATABASE to 0.
%
% UN*X: setenv REQUIREMENTS_DATABASE 0
% Windows: set REQUIREMENTS_DATABASE=0
%
% Leaving the variable unset or setting it to any value other than zero
% (including empty or NULL) causes REQUIREMENTS to use the database. I
% repeat, that means 'setenv REQUIREMENTS_DATABASE' will make REQUIREMENTS
% use the database. You must set this variable to zero to skip the database
% lookup.
%
% For R13b, the database only supports the MCR target. 
%
useDatabase = true;
reqDB = getenv('REQUIREMENTS_DATABASE');
if (~isempty(reqDB) && reqDB == '0') || ...
  tgt ~= matlab.depfun.internal.Target.MCR
    useDatabase = false;
end


% Possible input combinations:
%   1.  files
%   2.  files, target
%   3.  files, target, '-p', path_limit
%   4.  files, target, '-I', include_path
%   5.  files, target, '-c', components
%   6.  files, target, '-p', path_limit, '-I', include_path
%   7.  files, target, '-p', path_limit, '-I', include_path, '-c', components
%
% Not an exhaustive list. -p, -I and -c are optional and can appear in any
% order. files must appear first, always. If target is specified, it must
% be second.
%
% Extract the files and target, and pass the rest, unprocessed, to the 
% SearchPath constructor.

% Validate input count -- at least one, no more than eight.
maxArg = 8;
if ~useDatabase
    maxArg = 2;
end
narginchk(1,maxArg);


% FILES should be a cell array of strings. As a special case, allow a
% single file name string (wrap it in a cell array).
if ~iscell(files)
    if ischar(files) 
        files = { files };
    end
end

% Create a SearchPath object to scope the MATLAB path to the appropriate
% directories. Only necessary when -p or -I appears in the argument list,
% which happens whenever there are more than two arguments (in a
% well-formed call to requirements -- but we let the error detection code
% in SearchPath take care of checking the putative path manipulation
% arguments).
% If nargin <= 2 (nothing is specified), it should use the current path.
if nargin > 2 && useDatabase

    % Use the default database.
    s = matlab.depfun.internal.SearchPath(target, varargin{2:end});

    % Create an onCleanup object to ensure the MATLAB path is restored even
    % if an error occurs while computing the Completion. The onCleanup
    % function runs on normal function return also, so path restoration
    % occurs in either case.
    p = path;
    restorePath = onCleanup(@()path(p));
    
    % Set MATLAB's path to the SearchPath's PathString 
    % This may cause MATLAB:dispatcher:nameConflict warnings. It is the
    % caller's responsiblity to disable these, if necessary.
    path(s.PathString);
end

if getenv('REQUIREMENTS_VERBOSE')
    disp('Files: ');
    fprintf(1,'%s\n', sprintf(' %s', files{:}));
    if nargin > 1
        disp('Arguments:');
        for n = 2:nargin-1
            if ischar(varargin{n})
                fprintf(1,'  %s\n', varargin{n});
            elseif iscell(varargin{n})
                aN = varargin{n};
                for k = 1:numel(aN)
                    fprintf(1,'  ');
                    disp(aN{k});
                end
            end
        end
    end
    
    path
end

if useDatabase
    % use the database
    c = matlab.depfun.internal.Completion(files, tgt, 'useDatabase');
else
    % do not use the database
    c = matlab.depfun.internal.Completion(files, tgt);
end

if nargout == 1
    parts = c.parts();
elseif nargout >= 2
    [parts, resources.products, resources.platforms] = c.requirements(); 
end
if nargout > 2
    exclusions = c.excludedFiles();
end
