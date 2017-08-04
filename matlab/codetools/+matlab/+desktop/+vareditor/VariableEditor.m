classdef VariableEditor < handle
    % VariableEditor - provide access to a VariableEditor.
    
    %   Copyright 2011-2013 The MathWorks, Inc.
    
    properties (Dependent,Hidden)
        WindowLocation
        WindowVisible
    end
    
    properties (SetAccess=private)
        VariableName
    end
    
    properties (SetAccess=private,Hidden)
        WorkspaceHandle
    end
    
    properties (Access=private)
        RequestedWindowLocation
        WorkspaceID
        WorkspaceVariable
        VariableEditorPeer
    end
    
    methods (Static)
        function checkAvailable 
        if ~usejava('swing')    
            error(message('MATLAB:openvar:TheVariableEditorNotSupported'));
        end
        end
        
        function checkVariableName(expression)
        if ~ischar(expression)
            error(message('MATLAB:openvar:VariableNameAsString'));
        end
        
        first = min([strfind(expression, '.'), strfind(expression, '('), strfind(expression, '{')]);
        if isempty(first) || first == 1
            first = length(expression)+1;
        end
        
        if ~isvarname(expression(1:first-1))
            error(message('MATLAB:openvar:InvalidVariableName'));
        end
        end

    end
    
    methods
        function obj = VariableEditor(variableName, workspaceHandle, groupName)
        matlab.desktop.vareditor.VariableEditor.checkAvailable();

        matlab.desktop.vareditor.VariableEditor.checkVariableName(variableName);

        % workspaceHandle allows callers to open variables in a specific workspace.
        if nargin < 2
            workspaceHandle = '';
        end
        
        if nargin < 3
            groupName = '';
        end
        
        if ~isempty(workspaceHandle) && ~isequal(workspaceHandle,'default') 
            try
              % Throw error if an invalid reference variable is passed.
              % evalin needs an assignment variable as it will create an
              % 'ans' variable if the variableName is an expression(Ex:'var.a.b.c')
               tmpVar = evalin(workspaceHandle,variableName); %#ok<NASGU> %
               clear tmpVar;
            catch e
                error(message('MATLAB:openvar:NonExistentVariable',variableName));
            end
        end 


        if nargout
            com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();
        end

        
        obj.VariableName = variableName;
        obj.WorkspaceHandle = workspaceHandle;
        obj.WorkspaceID = workspacefunc('getworkspaceid',workspaceHandle);
        obj.RequestedWindowLocation = getDefaultScreenLocation(com.mathworks.mde.array.ArrayEditor.DEFAULT_SIZE.width);
        obj.WorkspaceVariable = com.mathworks.mlservices.WorkspaceVariable(obj.VariableName, obj.WorkspaceID);
        obj.VariableEditorPeer = com.mathworks.mde.array.ArrayEditor(obj.WorkspaceVariable, groupName);
        end
        
        function open(obj)
        location = obj.RequestedWindowLocation;
        point = java.awt.Point(location(1), location(2));
        obj.VariableEditorPeer.setWindowLocation(point)
        end
        
        function close(obj)
        if ~isempty(obj.VariableEditorPeer)
            obj.VariableEditorPeer.close();
        end
        end
        
        function refresh(obj)
        obj.VariableEditorPeer.refresh();
        end
        
        function set.WindowLocation(obj, xy)
        if ~isnumeric(xy) || ~isequal(size(xy),[1,2])
            error(message('MATLAB:openvar:LocationMustBeNumericVector'));
        end
        obj.RequestedWindowLocation = xy;
        if obj.WindowVisible
            obj.open();
        end
        end
        
        function xy = get.WindowLocation(obj)
        if obj.WindowVisible
            point = obj.VariableEditorPeer.getWindowLocation();
            xy = [point.x point.y];
        else
            xy = obj.RequestedWindowLocation;
        end
        end
        
        function visible = get.WindowVisible(obj)
        visible = ~isempty(obj.VariableEditorPeer) && obj.VariableEditorPeer.isWindowVisible();
        end
        
        function delete(obj)
        obj.close();
        end
        
    end
end

function location = getDefaultScreenLocation(w)
ssize = get(0,'ScreenSize');
% center left to right, top edge 1/3 from top of screen
screenWidth = ssize(3);
screenHeight = ssize(4);
targetPoint = [screenWidth / 2 screenHeight / 3];
x = targetPoint(1) - w / 2;
y = targetPoint(2);
location = [x y];
end
