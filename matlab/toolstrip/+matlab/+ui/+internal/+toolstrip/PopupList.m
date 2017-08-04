classdef PopupList < matlab.ui.internal.toolstrip.base.Container
    % Popup List
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.PopupList">PopupList</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.addSeparator">addSeparator</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.PopupListOpened">PopupListOpened</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupList.PopupListClosed">PopupListClosed</a>            
    %
    % See also matlab.ui.internal.toolstrip.ListItem, matlab.ui.internal.toolstrip.DropDownButton, matlab.ui.internal.toolstrip.SplitButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Access = private)
        ChildTypes = {...
                'matlab.ui.internal.toolstrip.PopupListPanel', ...
                'matlab.ui.internal.toolstrip.ListItem', ...
                'matlab.ui.internal.toolstrip.ListItemWithCheckBox', ...
                'matlab.ui.internal.toolstrip.ListItemWithTextField', ...
                'matlab.ui.internal.toolstrip.ListItemWithPopup', ...
                'matlab.ui.internal.toolstrip.PopupListHeader', ...
                'matlab.ui.internal.toolstrip.PopupListSeparator'};
    end
    
    events
        % Event sent upon popup is displayed.
        PopupListOpened
        % Event sent upon popup is hidden.
        PopupListClosed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PopupList()
            % Constructor "PopupList": 
            %
            %   Creates a popup list associated with a dropdown or
            %   split button or a list item with popup
            %
            %   Examples:
            %
            %       sub_item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot');
            %       sub_item2 = matlab.ui.internal.toolstrip.ListItem('Delete Plot');
            %       sub_popup = matlab.ui.internal.toolstrip.PopupList();
            %       sub_popup.addItem(sub_item1);
            %       sub_popup.addItem(sub_item2);
            %
            %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.ADD_16,'This is the description');
            %       item2 = matlab.ui.internal.toolstrip.ListItemWithPopup('Delete Plot',matlab.ui.internal.toolstrip.Icon.DELETE_16,'This is the description');
            %       item2.Popup = sub_popup;
            %
            %       popup = matlab.ui.internal.toolstrip.PopupList();
            %       popup.addItem(item1);
            %       popup.addItem(item2);
            %
            %       btn = matlab.ui.internal.toolstrip.DropDownButton('this is a drop down button');
            %       btn.Popup = popup;

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('PopupList');
        end
        
        %% Public API: add and remove
        function add(this, item, varargin)
            % Method "add":
            %
            %   "add(popuplist, item)": add an item at the end of the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item = matlab.ui.internal.toolstrip.ListItem('new')
            %       popup.add(item)
            %
            %   "add(popuplist, item, index)": insert an item at a specified location in the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item1 = matlab.ui.internal.toolstrip.ListItem('new')
            %       item2 = matlab.ui.internal.toolstrip.ListItem('old')
            %       popup.add(item1)
            %       popup.add(item2, 1)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', str, class(this)));
            end
        end
        
        function remove(this, item)
            % Method "remove":
            %
            %   "remove(popuplist, item)": remove an item from the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item1 = matlab.ui.internal.toolstrip.ListItem('new')
            %       item2 = matlab.ui.internal.toolstrip.ListItem('old')
            %       popup.remove(item1)
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
        
        function separator = addSeparator(this)
            % Method "addSeparator":
            %
            %   "separator = addSeparator(popup)": add a separator in the popup list.
            %   Example:
            %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.ADD_16,'This is the description','This is the help');
            %       item2 = matlab.ui.internal.toolstrip.ListItem('Delete Plot',matlab.ui.internal.toolstrip.Icon.DELETE,'This is the description','This is the help');
            %       popup = matlab.ui.internal.toolstrip.PopupList;
            %       popup.addItem(item1);
            %       popup.addSeparator;
            %       popup.addItem(item2);
            separator = matlab.ui.internal.toolstrip.PopupListSeparator();
            this.add(separator);
        end
        
%         %% Public API: render
%         function render(this, hostId)
%             % Method "render":
%             %
%             %   "render(popuplist)": display popup list in the view.
%             % 
%             if matlab.ui.internal.toolstrip.base.Utility.validate(hostId, 'string')
%                 this.dispatchEvent(struct('eventType','placePopupList','id',this.getId(),'hostId',hostId));
%                 this.setPeerProperty('hostId',hostId);
%             else
%                 error(message('MATLAB:toolstrip:container:invalidHostId'));
%             end
%         end
        
    end
    
    methods (Access = protected)
        
        function PeerEventCallback(this,~,data)
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'PopupListOpened') || strcmp(eventdata.EventData.EventType,'PopupListClosed')
                this.notify(eventdata.EventData.EventType);
            end
        end
        
    end
    
end
