function [fList, pList] = requiredFilesAndProducts(files, varargin)
% [fList, pList] = requiredFilesAndProducts(files[, 'toponly'])
%
% matlab.codetools.requiredFilesAndProducts is a function that provides 
% a list of user MATLAB program files and a list of MathWorks products 
% which one or more MATLAB program files require to run. 
% 
% Inputs:
%
%   files - A list of files needs to be analyzed. It can be either a char
%           array that contains the name of one MATLAB program file or a 
%           cell array of char arrays that contain the name of one or more  
%           MATLAB program files.
%
%   'toponly' - When this case insensitive string option is specified, 
%           the function returns only those files and products used 
%           directly by "files".
%
% Outputs:
%
%   fList - Full paths of user MATLAB program files required by "files". 
%           Note that MathWorks MATLAB program files are not required,
%           because they are installed with MATLAB or other MathWorks 
%           products.
%
%   pList - A list of MathWorks products required by "files". Each required 
%           product is described by name, version, and product number.            
%
%   Copyright 2013-2014 The MathWorks, Inc.

% Validation of the number of input arguments
narginchk(1, 2);

% Validation of the optional input argument
if nargin == 1
    toponly = false;
elseif nargin == 2
    % case insensitive
    if strcmpi(varargin{1}, 'toponly')
        toponly = true;
    else
        error(message('MATLAB:requiredFilesAndProducts:BadStringFlag', ...
                      varargin{1}));
    end
end

% Validation of the required input argument
if ischar(files)
    files = {files};
elseif iscell(files)    
    if ~iscellstr(files)
        invalidInput = ~cellfun(@(f)ischar(f), files);
        invalidInput = reshape(invalidInput, 1, []);
        error(message('MATLAB:requiredFilesAndProducts:NameMustBeChar', ...
                      num2str(find(invalidInput), '#%d ')));
    end
else
    error(message('MATLAB:requiredFilesAndProducts:InvalidInputType',...
                  1, class(files), 'cell or char'));
end

% Only analyze non-MathWorks MATLAB program files
tgt = matlab.depfun.internal.Target.parse('MATLAB');

% The following warnings are not necessary to find file and product
% dependencies. Find their original states before reaching this point, and
% restore them after the dependency analysis.
warnID = { 'MATLAB:Completion:NoEntryPoints' ...
           'MATLAB:Completion:CorrespondingMCodeIsEmpty' ...
           'MATLAB:Completion:NoCorrespondingMCode' };
orgState = cellfun(@(w)warning('off', w), warnID);
restoreWarn = onCleanup(@()arrayfun(@(s)warning(s), orgState));

% Initialize output argument(s)
fList = {};

try    
    % Dependency Analysis
    c = matlab.depfun.internal.Completion(files, tgt, toponly);

    % Outputs
    parts = c.parts();
    if ~isempty(parts)
        fList = {parts.path};
    end

    if nargout > 1
        pList = c.products();
    end
catch e
    throw(e);
end

end % The end of requiredFilesAndProducts
