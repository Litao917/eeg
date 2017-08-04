classdef QuickAccessBar < matlab.ui.internal.toolstrip.base.Container
    % Quick Access Bar (per toolstrip)
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = QuickAccessBar()
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('QuickAccessBar');
        end
        
        %% Public API: add and remove
        function add(this, item, varargin)
            if isa(item, 'matlab.ui.internal.toolstrip.impl.QuickAccessGroup')
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            end
        end
        
        function move(this, item, index)
            if isa(item, 'matlab.ui.internal.toolstrip.impl.QuickAccessGroup')
                if this.isChild(item)
                    % move component in MCOS object
                    tree_move(this, item.Index, index);
                    % move component in Peer Model
                    moveToTarget(item, this, index);
                end
            end
        end
        
        function remove(this, item)
            if isa(item, 'matlab.ui.internal.toolstrip.impl.QuickAccessGroup')
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                end
            end
        end
        
    end
    
    methods (Access = protected)
        
%         function PeerEventCallback(this,~,data)
%             % client side event
%             eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
%             switch eventdata.EventData.EventType
%                 case 'ItemMoved'
%                     % it does not trigger RefreshGalleryFromAPI event                    
%                     for ct=1:length(this.Children)
%                         if strcmp(this.Children(ct).getId(),eventdata.EventData.itemId)
%                             item = this.Children(ct);
%                             break;
%                         end
%                     end
%                     this.move(item, eventdata.EventData.newIndex+1);
%                     % refresh gallery
%                     this.Popup.notify('RefreshGallery');
%             end
%         end
        
    end
    
end
