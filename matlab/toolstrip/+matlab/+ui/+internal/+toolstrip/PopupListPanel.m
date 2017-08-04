classdef PopupListPanel < matlab.ui.internal.toolstrip.base.Container
    % Popup List Panel
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.PopupListPanel">PopupListPanel</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.addSeparator">addSeparator</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % See also matlab.ui.internal.toolstrip.ListItem, matlab.ui.internal.toolstrip.PopupList
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Access = private)
        ChildTypes = {'matlab.ui.internal.toolstrip.ListItem', ...
                'matlab.ui.internal.toolstrip.ListItemWithCheckBox', ...
                'matlab.ui.internal.toolstrip.ListItemWithTextField', ...
                'matlab.ui.internal.toolstrip.ListItemWithPopup', ...
                'matlab.ui.internal.toolstrip.PopupListHeader', ...
                'matlab.ui.internal.toolstrip.PopupListSeparator'};
    end
    
    %% ----------- User-visible properties --------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "MaxHeight": 
        %
        %   The maximum height in pixels after which to show a scroll bar.
        %   It is a positive finite integer in the unit of pixels.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.PopupListPanel('MaxHeight',200)
        MaxHeight
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PopupListPanel(varargin)
            % Constructor "PopupListPanel": 
            %
            %   Creates a popup list panel.  
            %
            %   Examples:
            %
            %       panel = matlab.ui.internal.toolstrip.PopupListPanel();
            %       panel = matlab.ui.internal.toolstrip.PopupListPanel('MaxHeight', 200);
            %
            %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.ADD_16,'This is the description');
            %       item2 = matlab.ui.internal.toolstrip.ListItemWithCheckBox('Delete Plot');
            %       panel.add(item1);
            %       panel.add(item2);
            %
            %       popup = matlab.ui.internal.toolstrip.PopupList();
            %       popup.addItem(panel);
            %
            %       btn = matlab.ui.internal.toolstrip.DropDownButton('this is a drop down button');
            %       btn.Popup = popup;

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('PopupListPanel',varargin{:});
        end
        
        %% Public API
        % Width
        function value = get.MaxHeight(this)
            % GET function for MaxHeight property.
            value = this.getPeerProperty('maxHeight');
            if isempty(value)
                value = [];
            end
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
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.maxHeight = 600;
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            % set optional properties
            ni = nargin-2;
            if rem(ni,2)~=0,
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'maxHeight'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'maxHeight'
                        value = varargin{ct+1};
                        if isempty(value)
                            widget_properties.(name) = '';
                        else
                            ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                            if ok
                                widget_properties.(name) = value;
                            else
                                error(message('MATLAB:toolstrip:container:invalidMaxHeight'))
                            end
                        end
                end
            end
        end
        
    end
    
end
