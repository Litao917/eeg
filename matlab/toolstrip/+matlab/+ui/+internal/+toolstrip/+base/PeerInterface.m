classdef (Abstract) PeerInterface < handle
    % Base class for MCOS toolstrip components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% -----------  User-invisible properties --------------------
    properties (GetAccess = protected, SetAccess = protected)
        % Peer Node
        Peer = []
    end

    properties (Abstract, Access = protected)
        % Peer Node
        Type
    end
    
    properties (Access = protected)
        % Listeners for view events
        PeerEventListener
        PropertySetListener
    end
    
    methods (Access = protected)
        
        % Create peer node and attach it to the orphan tree
        function createPeer(this, props_struct)
            type = this.Type;
            switch type
                case 'Action'
                    managers = matlab.ui.internal.toolstrip.base.ActionService.getInstance();
                    root = managers.Manager.getRoot();
                case 'PopupList'
                    managers = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
                    root = managers.PopupRoot;
                case 'GalleryPopup'
                    managers = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
                    root = managers.GalleryPopupRoot;
                case 'GalleryFavoriteCategory'
                    managers = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
                    root = managers.GalleryFavoriteCategoryRoot;
                case 'QuickAccessBar'
                    managers = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
                    root = managers.QABRoot;
                otherwise
                    managers = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
                    root = managers.OrphanRoot;
            end
            if nargin == 1
                this.Peer = root.addChild(type);                
            else
                % prepare property value pairs
                props_hash = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(props_struct);
                % create peer node and put it into orphan tree
                this.Peer = root.addChild(type, props_hash);
            end
            % add listeneer to peer node event coming from client node
            this.PropertySetListener = addlistener(this.Peer, 'propertySet', @(event, data) PropertySetCallback(this, event, data));
            this.PeerEventListener = addlistener(this.Peer, 'peerEvent', @(event, data) PeerEventCallback(this, event, data));
        end
        
        % Destroy peer node and all its children
        function destroyPeer(this)
            if ~isempty(this.Peer)
                this.Peer.destroy();
            end
        end
        
        % Move peer node
        function moveToTarget(this,target,varargin)
            %%
            if isjava(target)
                % target is already a peer node
                if nargin == 2
                    matlab.ui.internal.toolstrip.base.ToolstripService.getInstance.Manager.move(this.Peer,target);
                else
                    matlab.ui.internal.toolstrip.base.ToolstripService.getInstance.Manager.move(this.Peer,target,varargin{1}-1);
                end
            else
                % target is a MCOS object
                if nargin == 2
                    matlab.ui.internal.toolstrip.base.ToolstripService.getInstance.Manager.move(this.Peer,target.Peer);
                else
                    matlab.ui.internal.toolstrip.base.ToolstripService.getInstance.Manager.move(this.Peer,target.Peer,varargin{1}-1);
                end
            end                
        end
        
        % Get peer node property
        function value = getPeerProperty(this, property)
            % set property of a JS toolstrip component
            java_value = this.Peer.getProperty(property);
            value = matlab.ui.internal.toolstrip.base.Utility.convertFromJavaToMatlab(java_value);
        end
        
        % Set peer node property
        function setPeerProperty(this, property, value)
            java_value = matlab.ui.internal.toolstrip.base.Utility.convertFromMatlabToJava(value);
            hashmap = java.util.HashMap();
            hashmap.put('source','MCOS');
            this.Peer.setProperty(property, java_value, hashmap);
        end
        
        % Dispatch peer event from server to client
        function dispatchEvent(this, structure)
            hashmap = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(structure);
            this.Peer.dispatchEvent('peerEvent',this.Peer,hashmap);
        end
        
        function PropertySetCallback(this,src,data)
            % property set callback
            % display(['Either server or client side set a property: "' data.getData.get('key') '".'])
        end
        
        function PeerEventCallback(this,src,data)
            % no op
            % display(['Either server or client side peer event fired: "' data.getData().get('eventType') '".'])
        end
        
    end
    
end

