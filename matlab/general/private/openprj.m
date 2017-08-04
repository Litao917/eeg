function out=openprj(filename)
%OPENPRJ opens a deployment , MATLAB Coder project or Simulink Project. 
%
%   OPENPRJ(FILENAME) opens the deployment, MATLAB Coder project or
%   Simulink Project. If FILENAME is not a valid project file then it is
%   opened in the MATLAB Editor. 
%
%   See also DEPLOYTOOL, MCC, MBUILD, CODER, SIMULINKPROJECT

%   Copyright 2006-2012 The MathWorks, Inc.

out=[];

if ~usejava('swing')
	edit(filename);
    return;
end

% Try opening as a DEPLOYTOOL project:
try %#ok<TRYNC>
    com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();
    valid = i_openDeploymentProject(filename, java.io.File(filename));
    if valid
        return
    end
end

% Try opening as a Simulink Project:
if com.mathworks.jmi.Matlab.isSimulinkAvailable
    % Simulink is available, but may not have a license.
    try %#ok<TRYNC>
        valid = i_openSimulinkProject(filename);
        if valid
            return
        end
    end
end

% We do not have a product installed that uses this .prj file, so treat it
% like a third-party file.
edit(filename);
return;
end


function valid = i_openDeploymentProject(filename, projectFile)
% Try to open as a Deployment Project:
if ~projectFile.isAbsolute()
    projectFile = java.io.File(java.io.File(pwd), filename);
end

valid = com.mathworks.project.impl.model.ProjectManager.isProject(projectFile);
if valid
    if ~isempty(which('deploytool'))
        try
            deploytool(filename);
        catch
            com.mathworks.project.impl.DeployTool.invoke(projectFile);
        end
    else
        com.mathworks.project.impl.DeployTool.invoke(projectFile);
    end
end
end

function valid = i_openSimulinkProject(filename)

    % Do not use an import here because MATLAB will fail to parse the entire file
    % when the imported class doesn't exist (i.e. slproject not installed)
    valid =  Simulink.ModelManagement.Project.File.PathUtils.loadProjectForOpenPRJ(filename);

end
