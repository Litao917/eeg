classdef Toolstrip < matlab.ui.internal.toolstrip.base.Container
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.Toolstrip">Toolstrip</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.DisplayState">DisplayState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.SelectedTab">SelectedTab</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.DisplayStateChangedFcn">DisplayStateChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.addTabGroup">addTabGroup</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.render">render</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.DisplayStateChanged">DisplayStateChanged</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Toolstrip.SelectedTabChanged">SelectedTabChanged</a>    
    %
    % See also matlab.ui.internal.toolstrip.TabGroup, matlab.ui.internal.toolstrip.Tab
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "SelectedTab": 
        %
        %   The currently selected Tab 
        %   It is a reference to the Tab object and the default value is [].
        %   It is read-only.
        %
        %   Example:
        %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
        %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
        %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
        %       tabgroup.add(tab1)
        %       tabgroup.add(tab2)
        %       tabgroup.SelectedTab = tab1 % select tab1 as current
        SelectedTab
    end
    
    properties (Dependent, Access = public)
        % Property "DisplayState": 
        %
        %   It takes one of the following strings: "expanded" (default),
        %   "collapsed" and "expanded_on_top".  The property is writable.
        %   Use this property to change the toolstrip display state.
        %
        %   Example:
        %       ts = matlab.ui.internal.toolstrip.Toolstrip()
        %       ts.DisplayState = 'collpased' % initialize toolstrip to be collapsed 
        DisplayState
        % Property "DisplayStateChangedFcn": 
        %
        %   Button text.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button
        %       btn.Text = 'Submit'
        DisplayStateChangedFcn
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = private)
        DisplayStateChangedFcn_ = []
        SelectedTabChangedListeners = []
        QuickAccessBar_   
    end
    
    % ----------------------------------------------------------------------------
    events
        % Event "DisplayStateChanged": 
        %
        %   Fires toolstrip is collapsed or expanded
        %
        %   Example:
        %       ts = matlab.ui.internal.toolstrip.Toolstrip()
        %       listener = ts.addlistener('DisplayStateChanged',@YourCallback)
        DisplayStateChanged
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
        function this = Toolstrip()
            % Constructor "Toolstrip": 
            %
            %   Create a toolstrip.
            %
            %   Examples:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip();
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Toolstrip');
        end
        
        %% Public API: Get/Set Properties
        % DisplayState
        function value = get.DisplayState(this)
            % GET function for DisplayState property.
            value = this.getPeerProperty('displayState');
        end
        function set.DisplayState(this, value)
            % SET function for DisplayState property.
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'display_state')
                this.setPeerProperty('displayState',lower(value));
            else
                error(message('MATLAB:toolstrip:container:invalidDisplayState'))
            end
        end
        % DisplayStateChangedFcn
        function value = get.DisplayStateChangedFcn(this)
            % GET function for DisplayStateChangedFcn property.
            value = this.DisplayStateChangedFcn_;
        end
        function set.DisplayStateChangedFcn(this, value)
            % SET function for DisplayStateChangedFcn property.
            if internal.Callback.validate(value)
                this.DisplayStateChangedFcn_ = value;
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', 'DisplayStateChanged'))
            end
        end
        % SelectedTab
        function obj = get.SelectedTab(this)
            % GET function for SelectedTab property.
            obj = [];
            for ct=1:length(this.Children)
                obj = this.Children(ct).SelectedTab;
                if ~isempty(obj)
                    break;
                end
            end
        end
        
        function delete(this)
            this.SelectedTabChangedListeners = [];
        end
        
        %% Public API: Add/Remove Methods
        function add(this, tabgroup, varargin)
            % Method "add":
            %
            %   "add(ts, tabgroup)": add a TabGroup object at the end of the toolstrip.
            %   Example:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip()
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       ts.add(tabgroup)
            %
            %   "add(ts, tabgroup, index)": insert a TabGroup at a specified location in the toolstrip.
            %   Example:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip()
            %       tabgroup1 = matlab.ui.internal.toolstrip.TabGroup()
            %       ts.add(tabgroup1)
            %       tabgroup2 = matlab.ui.internal.toolstrip.TabGroup()
            %       ts.add(tabgroup2,1) % insert tabgroup2 as the first tab group
            if isa(tabgroup, 'matlab.ui.internal.toolstrip.TabGroup')
                add@matlab.ui.internal.toolstrip.base.Container(this, tabgroup, varargin{:});
                if nargin==2
                    % append
                    add@matlab.ui.internal.toolstrip.base.Container(this.QuickAccessBar_, tabgroup.getQuickAccessGroup(), 1);
                else
                    % insert
                    index = length(this.Children)+2-varargin{1};
                    add@matlab.ui.internal.toolstrip.base.Container(this.QuickAccessBar_, tabgroup.getQuickAccessGroup(), index);
                end
                this.SelectedTabChangedListeners = [this.SelectedTabChangedListeners; addlistener(tabgroup, 'SelectedTabChanged', @(src, event) SelectedTabChangedCallback(this, src, event))];
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(tabgroup), class(this)));
            end
        end
        
        function remove(this, tabgroup)
            % Method "remove":
            %
            %   "remove(ts, tabgroup)": remove a TabGroup object from the toolstrip.
            %   Example:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip()
            %       tabgroup1 = matlab.ui.internal.toolstrip.TabGroup()
            %       tabgroup2 = matlab.ui.internal.toolstrip.TabGroup()
            %       ts.add(tabgroup1)
            %       ts.add(tabgroup2)
            %       ts.remove(tabgroup1) % now only tabgroup2 displayed
            if isa(tabgroup, 'matlab.ui.internal.toolstrip.TabGroup')
                if this.isChild(tabgroup)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, tabgroup);
                    remove@matlab.ui.internal.toolstrip.base.Container(this.QuickAccessBar_, tabgroup.getQuickAccessGroup());
                    for ct=1:length(this.SelectedTabChangedListeners)
                        if this.SelectedTabChangedListeners(ct).Source{1}==tabgroup
                            this.SelectedTabChangedListeners(ct) = [];
                            break;
                        end
                    end
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(tabgroup), class(this)));
            end
        end
        
        function tabgroup = addTabGroup(this)
            % Method "addTabGroup":
            %
            %   "tabgroup = addTabGroup(ts)": create a TabGroup object at
            %   the end of the toolstrip and returns its handle. Example:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip()
            %       tabgroup = ts.addTabGroup()
            tabgroup = matlab.ui.internal.toolstrip.TabGroup();
            this.add(tabgroup);
        end
        
        %% Public API: render
        function render(this, hostId)
            % Method "render":
            %
            %   "render(ts, div_id)": display toolstrip in the div.
            %
            %   Example:
            %       ts = matlab.ui.internal.toolstrip.Toolstrip()
            %       tabgroup = ts.addTabGroup()
            %       tab = tabgroup.addTab('title1')
            %       ts.render('myDIV')
            
            if matlab.ui.internal.toolstrip.base.Utility.validate(hostId, 'string')
                % move toolstrip peer node from orphan root to visible root 
                this.setPeerProperty('hostId',hostId);
                root = matlab.ui.internal.toolstrip.base.ToolstripService.getInstance().ToolstripRoot;
                this.moveToTarget(root);
                this.dispatchEvent(struct('eventType','placeToolStrip','id',this.getId(),'hostId',hostId));
            else
                error(message('MATLAB:toolstrip:container:invalidHostId'));
            end
        end

    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.QABId = '';
            properties.displayState = 'expanded';
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            % create favorite
            this.QuickAccessBar_ = matlab.ui.internal.toolstrip.impl.QuickAccessBar();
            widget_properties.QABId = this.QuickAccessBar_.getId();
        end
        
        function PropertySetCallback(this,~,data)
            originator = data.getOriginator();
            if ~(isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS'))
                % client side event
                if strcmp(data.getData.get('key'),'displayState')
                    new_eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(struct(...
                        'Property','DisplayState','OldValue',data.getData.get('oldValue'),'NewValue',data.getData.get('newValue')));
                    internal.Callback.execute(this.DisplayStateChangedFcn_, this, new_eventdata);
                    this.notify('DisplayStateChanged',new_eventdata);
                end
            end
        end
        
        function SelectedTabChangedCallback(this, ~, event)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(struct(...
                'Property','SelectedTab','TabGroup',event.Source,...
                'OldValue',event.EventData.OldValue,'NewValue',event.EventData.NewValue));
            if isvalid(this)
                this.notify('SelectedTabChanged',eventdata);
            end
        end
        
    end
    
end
