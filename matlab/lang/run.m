function run(scriptname)
%RUN Run script.
%   Typically, you just type the name of a script at the prompt to
%   execute it.  This works when the script is on your path.  Use CD
%   or ADDPATH to make the script executable from the prompt.
%
%   RUN is a convenience function that runs scripts that are not
%   currently on the path.
%
%   RUN SCRIPTNAME runs the specified script.  If SCRIPTNAME contains
%   the full pathname to the script, then RUN changes the current
%   directory to where the script lives, executes the script, and then
%   changes back to the original starting point.  The script is run
%   within the caller's workspace.
%

%   NOTES:
%     * If SCRIPTNAME attempts to CD into its own folder, RUN cannot detect
%       this change. In this case, RUN will revert to the starting folder
%       on exit.
%     * If SCRIPTNAME is a MATLAB file and there is a P-file in the same
%       folder, RUN silently executes the P-file.
%
%   See also CD, ADDPATH.

%   Copyright 1984-2013 The MathWorks, Inc.

if isempty(scriptname)
   return;
end
if ispc
   scriptname = strrep(scriptname,'/','\');
end

[fileDir,script,ext] = fileparts(scriptname);
startDir = pwd;
if ~isempty(fileDir)%There is a directory with SCRIPTNAME; must change folders.
   if ~exist(fileDir,'dir')
      error(message('MATLAB:run:FileNotFound',scriptname));
   end 
   cd(fileDir);
   fileDir = pwd;
   cleaner = onCleanup(@() resetCD(startDir,fileDir));
   pathscript = which(script);
   if isempty(pathscript)
      error(message('MATLAB:run:CannotExecute',scriptname));
   end
   [fileDir,~,rext] = fileparts(pathscript);
   if ~strcmp(fileDir,pwd)
      error(message('MATLAB:run:FileNotFound',scriptname));
   end
else  % No directory given, expect script is on the path
   [runDir,~,rext] = fileparts(which(script));
   if isempty(runDir)
      error(message('MATLAB:run:FileNotFound',scriptname));
   end
end
if ~isempty(ext) ...
      && ~strcmp(ext,rext)...
      && ~(strcmp(ext,'.m') && strcmp(rext,'.p'))
   error(message('MATLAB:run:CannotExecute',scriptname));
end
evalin('caller', [script ';']);

%Clean-up function is nested to catch the state of the function workspace
end

function resetCD(returnDir,tempDir)
if strcmp(tempDir,pwd)
   cd(returnDir);
end
end
%on exit in case of an error.

