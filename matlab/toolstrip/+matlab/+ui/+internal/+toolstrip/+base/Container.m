classdef (Abstract) Container < matlab.ui.internal.toolstrip.base.Component
    % Base class for MCOS toolstrip container components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    methods
        
        %% Constructor
        function this = Container(type, varargin)
            % set type
            this.Type = type;
            widget_properties = this.getDefaultWidgetProperties();
            widget_properties = this.getCustomWidgetProperties(widget_properties, varargin{:});
            this.createPeer(widget_properties);
        end
        
        function add(this, component, varargin)
            % Add component as a child to this parent in MCOS object
            if nargin == 2
                % append to the end
                tree_add(this, component);
            else
                % insert at specified indexed location
                tree_insert(this, component, varargin{1});
            end
            % Add component as a child to this parent in Peer Model
            component.moveToTarget(this, varargin{:});
        end
        
        function remove(this, component)
            % Remove component from the children list of MCOS object
            tree_remove(this, component);
            % Remove component from the children list of Peer Model
            component.moveToTarget(matlab.ui.internal.toolstrip.base.ToolstripService.getInstance().OrphanRoot);
        end
        
        function obj = find(this, tag)
            % Method "find":
            %
            %   "find(container, tag)": return the first object with
            %   specified tag if it exists anywhere in the container or []
            %   if not found. The container can be toolstrip, tabgroup,
            %   tab, section, panel, column and popuplist.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = ts1.find('sec1') % returns the handle to the section

            % Process input
            if ischar(tag)
                obj = tree_deep_search(this, tag);
            else
                error(message('MATLAB:toolstrip:container:invalidFind'));
            end
        end
        
        function objs = findAll(this, tag)
            % Method "findAll":
            %
            %   "findAll(container, tag)": return all the objects with
            %   specified tag if they exist anywhere in the container or []
            %   if not found. The container can be toolstrip, tabgroup,
            %   tab, section, panel, column and popuplist.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = ts1.findAll('sec1') % returns the handle to the section

            % Process input
            if ischar(tag)
                objs = tree_deep_search_all(this, tag);
            else
                error(message('MATLAB:toolstrip:container:invalidFindAll'));
            end
        end
        
        function obj = get(this, arg)
            % Method "get":
            %
            %   "get()": return all the direct children of the
            %   container or [] if none exists.
            %
            %   "get(container, tag)": return the first object with
            %   specified tag if it exists as the direct child of the
            %   container or error out if not found. The container can be
            %   toolstrip, tabgroup, tab, section, panel, column and
            %   popuplist.
            %
            %   "get(container, index)": return the direct child of the
            %   container with specified index. The container can be
            %   toolstrip, tabgroup, tab, section, panel, column and
            %   popuplist.  "index" is 1-based.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = ts1.get(1) % returns the handle to the section

            % Process input
            if nargin == 1
                obj = this.Children;
            elseif ischar(arg)
                obj = tree_flat_search(this, arg);
                if isempty(obj)
                    error(message('MATLAB:toolstrip:container:failedGetByTag'));
                end
            elseif isnumeric(arg) && isscalar(arg) && isfinite(arg) && mod(arg,1)==0
                if arg>0 && arg<=length(this.Children)
                    obj = tree_flat_search(this, arg);
                else
                    error(message('MATLAB:toolstrip:container:failedGetByIndex'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidGet'));                
            end
        end
        
        function disableAll(this)
            % Method "disableAll":
            %
            %   "disableAll(container)": disables all the controls
            %   hosted by the container. The container can be toolstrip,
            %   tabgroup, tab, section, panel, column and popuplist.
            %
            %   Example:
            %       % tab.disableAll()

            for ct=1:length(this.Children)
                if isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Container')
                    this.Children(ct).disableAll();
                elseif isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Control')
                    this.Children(ct).Enabled = false;
                end
            end
        end
        
        function enableAll(this)
            % Method "enableAll":
            %
            %   "enableAll(container)": enables all the controls
            %   hosted by the container. The container can be toolstrip,
            %   tabgroup, tab, section, panel, column and popuplist.
            %
            %   Example:
            %       % tab.enableAll()

            for ct=1:length(this.Children)
                if isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Container')
                    this.Children(ct).enableAll();
                elseif isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Control')
                    this.Children(ct).Enabled = true;
                end
            end
        end
        
    end
    
    methods (Access = protected)

        function obj = findChildByID(this,id)
            obj = [];
            for ct=1:length(this.Children)
                if strcmp(this.Children(ct).getId(),id)
                    obj = this.Children(ct);
                    return;
                end
            end
        end            
        
        function rules = getInputArgumentRules(this) %#ok<*MANU>
            rules = struct;
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            if nargin>2
                rules = this.getInputArgumentRules();
                [~, widget_properties] = matlab.ui.internal.toolstrip.base.Utility.updateProperties(rules, struct, widget_properties, varargin{:}); 
            end
        end
        
    end
    
end