classdef (Sealed) ToolstripService < handle
    % Singleton message center handles communications between web browser
    % and MATLAB via connector messaging API.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = private)
        % Manager
        Manager
        % ToolstripRoot
        ToolstripRoot
        % OrphanRoot
        OrphanRoot
        % PopupRoot
        PopupRoot
        % QABRoot
        QABRoot
        % GalleryRoot
        GalleryRoot
        GalleryPopupRoot
        GalleryFavoriteCategoryRoot
    end

    methods (Access = private)
        
        function this = ToolstripService()
            % constructor
            % create toolstrip channel (one per MATLAB session)
            this.Manager = com.mathworks.peermodel.PeerModelManagers.getInstance('/ToolstripPeerModelChannel');
            this.Manager.setSyncEnabled(true);
            % create root
            if ~this.Manager.hasRoot()
                props = java.util.HashMap();
                Root = this.Manager.setRoot('Root', props);
                this.OrphanRoot = Root.addChild('OrphanRoot', props);
                this.PopupRoot = Root.addChild('PopupRoot', props);
                this.QABRoot = Root.addChild('QABRoot', props);
                this.GalleryRoot = Root.addChild('GalleryRoot', props);
                this.GalleryPopupRoot = this.GalleryRoot.addChild('GalleryPopupRoot', props);
                this.GalleryFavoriteCategoryRoot = this.GalleryRoot.addChild('GalleryFavoriteCategoryRoot', props);
                % toolstrip root must be the last root node because of the
                % refreshing order is from first to last.  the other
                % utility roots such as popup and gallery must be refreshed
                % before the toolstrip root because of the dependency.
                this.ToolstripRoot = Root.addChild('ToolstripRoot', props);
            end
        end
        
    end
    
    methods (Static)
        
        function singleObj = getInstance()
            % singleton
            mlock
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj) || isempty(localObj.Manager) || ~localObj.Manager.hasRoot()
                localObj = matlab.ui.internal.toolstrip.base.ToolstripService();
            end
            singleObj = localObj;
        end
        
        function cleanup()
            mgr = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
            mgr.Manager = [];
            mgr.ToolstripRoot = [];
            mgr.OrphanRoot = [];
            mgr.PopupRoot = [];
            mgr.QABRoot = [];
            mgr.GalleryRoot = [];
            mgr.GalleryPopupRoot = [];
            mgr.GalleryFavoriteCategoryRoot = [];
            com.mathworks.peermodel.PeerModelManagers.cleanup('/ToolstripPeerModelChannel');
        end
            
        function reset()
            % get manager
            mgr = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance();
            if isempty(mgr.Manager)
                % create toolstrip channel (one per MATLAB session)
                mgr.Manager = com.mathworks.peermodel.PeerModelManagers.getInstance('/ToolstripPeerModelChannel');
                mgr.Manager.setSyncEnabled(true);
            end
            % remove all children
            if mgr.Manager.hasRoot()
                mgr.Manager.getRoot.remove();
            end
            % empty PV
            props = java.util.HashMap();
            % Root
            Root = mgr.Manager.setRoot('Root', props);
            % Orphan
            mgr.OrphanRoot = Root.addChild('OrphanRoot', props);
            % Popup
            mgr.PopupRoot = Root.addChild('PopupRoot', props);
            % QAB
            mgr.QABRoot = Root.addChild('QABRoot', props);
            % Gallery
            mgr.GalleryRoot = Root.addChild('GalleryRoot', props);
            mgr.GalleryPopupRoot = mgr.GalleryRoot.addChild('GalleryPopupRoot', props);
            mgr.GalleryFavoriteCategoryRoot = mgr.GalleryRoot.addChild('GalleryFavoriteCategoryRoot', props);
            % Toolstrip
            mgr.ToolstripRoot = Root.addChild('ToolstripRoot', props);
        end
        
    end
        
end