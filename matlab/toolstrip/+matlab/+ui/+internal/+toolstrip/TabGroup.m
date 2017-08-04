classdef TabGroup < matlab.ui.internal.toolstrip.base.Container
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.TabGroup">TabGroup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.SelectedTab">SelectedTab</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.SelectedTabChangedFcn">SelectedTabChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.addTab">addTab</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.remove">remove</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TabGroup.SelectedTabChanged">SelectedTabChanged</a>    
    %
    % See also matlab.ui.internal.toolstrip.Toolstrip, matlab.ui.internal.toolstrip.Tab
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "SelectedTab": 
        %
        %   The currently selected Tab 
        %   It is a reference to the Tab object and the default value is [].
        %   It is writable.
        %
        %   Example:
        %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
        %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
        %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
        %       tabgroup.add(tab1)
        %       tabgroup.add(tab2)
        %       tabgroup.SelectedTab = tab1 % select tab1 as current
        SelectedTab
        % Property "DisplayStateChangedFcn": 
        %
        %   Button text.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button
        %       btn.Text = 'Submit'
        SelectedTabChangedFcn
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = private)
        SelectedTabChangedFcn_ = []
        QuickAccessGroup_   
    end
    
    % ----------------------------------------------------------------------------
    events
        % Event "SelectedTabChanged": 
        %
        %   Fires when a new tab is selected from GUI
        %
        %   Example:
        %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
        %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
        %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
        %       tabgroup.add(tab1)
        %       tabgroup.add(tab2)
        %       listener = tabgroup.addlistener('SelectedTabChanged',@YourCallback)
        SelectedTabChanged
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = TabGroup()
            % Constructor "TabGroup": 
            %
            %   Create a tab group.
            %
            %   Examples:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup();
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('TabGroup');
        end
        
        %% Public API: Get/Set
        % SelectedTab
        function obj = get.SelectedTab(this)
            % GET function for SelectedTab property.
            peernode_id = this.getPeerProperty('selectedTab');
            obj = this.findChildByID(peernode_id);
        end
        
        function set.SelectedTab(this, obj)
            % SET function for SelectedTab property.
            if isempty(obj)
                error(message('MATLAB:toolstrip:container:invalidSelectedTab'));
                %this.setPeerProperty('selectedTab','');                
            else
                if ~isa(obj, 'matlab.ui.internal.toolstrip.Tab')
                    error(message('MATLAB:toolstrip:container:invalidSelectedTab'));
                elseif ~this.isChild(obj)
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
                % PostSet event will be sent over to the view adapter
                this.setPeerProperty('selectedTab',obj.getId());
            end
        end
        % SelectedTabChangedFcn
        function value = get.SelectedTabChangedFcn(this)
            % GET function for SelectedTabChangedFcn property.
            value = this.SelectedTabChangedFcn_;
        end
        function set.SelectedTabChangedFcn(this, value)
            % SET function for SelectedTabChangedFcn property.
            if internal.Callback.validate(value)
                this.SelectedTabChangedFcn_ = value;
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', 'SelectedTabChangedFcn'))
            end
        end
        
        %% Public API: tab management
        function add(this, tab, varargin)
            % Method "add":
            %
            %   "add(tabgroup, tab)": add a tab object at the end of the tab group.
            %   Example:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
            %       tabgroup.add(tab1)
            %
            %   "add(tabgroup, tab, index)": insert a tab at a specified location in the tab group.
            %   Example:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
            %       tabgroup.add(tab1)
            %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
            %       tabgroup.add(tab2,1) % insert tab2 as the first tab
            if isa(tab, 'matlab.ui.internal.toolstrip.Tab')
                add@matlab.ui.internal.toolstrip.base.Container(this, tab, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(tab), class(this)));
            end
        end
        
        function remove(this, tab)
            % Method "remove":
            %
            %   "remove(tabgroup, tab)": remove a tab object from the tab group.
            %   Example:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
            %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
            %       tabgroup.add(tab1)
            %       tabgroup.add(tab2)
            %       tabgroup.remove(tab1) % now tab2 becomes the only tab
            if isa(tab, 'matlab.ui.internal.toolstrip.Tab')
                if this.isChild(tab)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, tab);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(tab), class(this)));
            end
        end
        
        function tab = addTab(this, varargin)
            % Method "addTab":
            %
            %   "tab1 = addTab(tabgroup, 'title1')": create a tab object at the end
            %   of the toolstrip and returns its handle. 
            %   Example:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       tab1 = tabgroup.addTab('tab1')
            try
                tab = matlab.ui.internal.toolstrip.Tab(varargin{:});
            catch E
                throw(E)
            end
            this.add(tab);
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.QAGroupId = '';
            properties.selectedTab = '';
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            % create favorite
            this.QuickAccessGroup_ = matlab.ui.internal.toolstrip.impl.QuickAccessGroup();
            widget_properties.QAGroupId = this.QuickAccessGroup_.getId();
        end
        
        function PropertySetCallback(this,~,data)
            originator = data.getOriginator();
            if ~(isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS'))
                % client side event
                if strcmp(data.getData.get('key'),'selectedTab')
                    old_id = data.getData.get('oldValue');
                    new_id = data.getData.get('newValue');
                    old_tab = this.findChildByID(old_id);
                    new_tab = this.findChildByID(new_id);
                    new_eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(struct(...
                        'Property','SelectedTab','OldValue',old_tab,'NewValue',new_tab));
                    internal.Callback.execute(this.SelectedTabChangedFcn_, this, new_eventdata);
                    this.notify('SelectedTabChanged',new_eventdata);
                end
            end
        end
        
    end
    
    methods (Access = {?matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess, ?matlab.ui.internal.toolstrip.Toolstrip})
        
        function value = getQuickAccessGroup(this)
            value = this.QuickAccessGroup_;
        end
        
    end
    
end
