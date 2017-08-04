function package(projectFile)
% matlab.apputil.package Package an app into an MLAPPINSTALL file.
%
%   matlab.apputil.package(PRJFILE) will create an MLAPPINSTALL file based
%   on the information contained in the project file specified by PRJFILE.
%   The PRJFILE argument is a string containing the name of the project
%   file to use.  The file can be specified with either an absolute path or
%   a path relative to the current directory.  Use matlab.apputil.create to
%   create the project file.
%
%   See also: matlab.apputil.create, matlab.apputil.install.

% Copyright 2012 The MathWorks, Inc.

narginchk(1,1);

validateattributes(projectFile, {'char'}, {'row', 'vector'}, '', 'PRJFILE');

fullFileName = matlab.internal.apputil.AppUtil.locateFile(projectFile,  matlab.internal.apputil.AppUtil.ProjectFileExtension);
if isempty(fullFileName)
    error(message('MATLAB:apputil:package:filenotfound', projectFile));
end


validProject = matlab.internal.apputil.AppUtil.validateProjectFile(fullFileName);

if ~validProject
    error(message('MATLAB:apputil:package:invalidproject'));
end

% create a project configuration
import com.mathworks.project.impl.plugin.*
import com.mathworks.project.impl.model.*
import com.mathworks.project.api.*
import com.mathworks.project.impl.*
import java.io.File

ProjectManager.init();
instance = ProjectApi.getInstance();
projectFile = File(fullFileName);
configuration = instance.openProject( projectFile);
buildProcess = instance.createBuildProcess(configuration, projectFile);
buildProcess.start();
pause(1);
