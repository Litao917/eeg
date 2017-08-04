classdef QuickAccessGroup < matlab.ui.internal.toolstrip.base.Container
    % Quick Access Bar (per toolstrip)
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Access = private)
        ChildTypes = {...
                'matlab.ui.internal.toolstrip.impl.QABPushButton', ...
                'matlab.ui.internal.toolstrip.impl.QABDropDownButton', ...
                'matlab.ui.internal.toolstrip.impl.QABSplitButton', ...
                'matlab.ui.internal.toolstrip.impl.QABToggleButton'};
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = QuickAccessGroup()
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('QuickAccessGroup');
        end
        
        %% Public API: add and remove
        function add(this, item, varargin)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', str, class(this)));
            end
        end
        
        function move(this, item, index)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                if this.isChild(item)
                    % move component in MCOS object
                    tree_move(this, item.Index, index);
                    % move component in Peer Model
                    moveToTarget(item, this, index);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectMove', class(item), class(this)));
            end
        end
        
        function remove(this, item)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(item), class(this)));
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
