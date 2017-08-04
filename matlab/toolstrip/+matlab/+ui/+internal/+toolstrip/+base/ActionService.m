classdef (Sealed) ActionService < handle
    % Singleton message center handles communications between web browser
    % and MATLAB via connector messaging API.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = private)
        % Manager
        Manager
    end

    methods (Access = private)
        
        function this = ActionService()
            % constructor
            % create toolstrip channel (one per MATLAB session)
            this.Manager = com.mathworks.peermodel.PeerModelManagers.getInstance('/ToolstripAction/Server');
            this.Manager.setSyncEnabled(true);
            % create root
            if ~this.Manager.hasRoot()
                this.Manager.setRoot('Root', java.util.HashMap);
            end
        end
        
    end
    
    methods (Static)
        
        function singleObj = getInstance()
            % singleton
            mlock
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj) || isempty(localObj.Manager) || ~localObj.Manager.hasRoot()
                localObj = matlab.ui.internal.toolstrip.base.ActionService();
            end
            singleObj = localObj;
        end
        
        function cleanup()
            mgr = matlab.ui.internal.toolstrip.base.ActionService.getInstance();
            mgr.Manager = [];
            com.mathworks.peermodel.PeerModelManagers.cleanup('/ToolstripAction/Server');
        end
        
        function reset()
            mgr = matlab.ui.internal.toolstrip.base.ActionService.getInstance();
            if isempty(mgr.Manager)
                % create toolstrip channel (one per MATLAB session)
                mgr.Manager = com.mathworks.peermodel.PeerModelManagers.getInstance('/ToolstripAction/Server');
                mgr.Manager.setSyncEnabled(true);
            end
            if mgr.Manager.hasRoot()
                mgr.Manager.getRoot.remove();
            end
            mgr.Manager.setRoot('Root', java.util.HashMap);
        end
        
    end
        
end