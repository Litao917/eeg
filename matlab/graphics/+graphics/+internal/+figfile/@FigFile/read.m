function read(obj, filename)
%read   Read a file and store its contents in the object
%
%  read(obj, file) reads the contents of the specified figure
%  file and store them in the FigFile object.  Any existing
%  data that is being held by the FigFile will be discarded.
%
%  read(obj) reads the contents of the file that the Path
%  property is set to.

%  Copyright 2011-2012 The MathWorks, Inc.

if nargin <2
    filename = obj.Path;
end

if isempty(filename)
    error(message('MATLAB:graphics:internal:figfile:FigFile:EmptyFilename'));
end

% Disable warnings that appear if there are no hg variables in the file
ws = warning('off', 'MATLAB:load:variablePatternNotFound');
clean_ws = onCleanup(@() warning(ws));

if graphicsversion('handlegraphics')
    % running HG1 - only look for hgS
    hgDataVars = load(filename, '-mat', '-regexp', '^hg[S]');
else
 
    hgDataVars = load(filename, '-mat', '-regexp', '^hg[SM]');
        
end

AllVarNames = fieldnames(hgDataVars);

% Find hgS... variables
vars_hgS = regexp(AllVarNames, '^hgS.*', 'once', 'match');
vars_hgS = vars_hgS(~cellfun(@isempty, vars_hgS));

% find hgM... variables
vars_hgM = regexp(AllVarNames, '^hgM.*', 'once', 'match');
vars_hgM = vars_hgM(~cellfun(@isempty, vars_hgM));

% Fig format version
FigVer = -1;

% Saved-in version string
SavedVer = '';

if length(vars_hgS)==1
    % Version 2 files should have an hgS variable.
    FigVer = 2;
    SavedVer = vars_hgS{1};
    obj.Format2Data = hgDataVars.(vars_hgS{1});
end

if length(vars_hgM)==1
    % Version 3 files should also have an hgM.
    FigVer = 3;
    SavedVer = vars_hgM{1};
    obj.Format3Data = hgDataVars.(vars_hgM{1}).GraphicsObjects.Format3Data;
end

obj.Path = filename;
obj.FigFormat = FigVer;

% Get the version that saved the file from the variable name
obj.RequiredMatlabVersion = localGetSaveVersion(SavedVer);
end



function VerNum = localGetSaveVersion(varname)
% Parse the saved version from a variable name string
VerNum = -1;
VerString = regexp(varname, '_(.*)$', 'once', 'tokens');
if ~isempty(VerString)
    VerNum = str2double(VerString{1});
end
end
