classdef (Abstract) Component < matlab.ui.internal.toolstrip.base.Node & matlab.ui.internal.toolstrip.base.PeerInterface
    % Base class for MCOS toolstrip components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% ----------------------------------------------------------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "Index": 
        %
        %   The index of the object in the parent container It is a
        %   positive integer when the object has a hosting container,
        %   otherwise it is [].  The property is read-only.
        %
        %   Example:
        %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
        %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
        %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
        %       tabgroup.add(tab1)
        %       tabgroup.add(tab2)
        %       tab1.Index % return 1
        %       tabgroup.remove(tab1)
        %       tab1.Index % return []
        Index;
    end
    
    properties (Dependent, Access = public)
        % Property "Tag": 
        %
        %   The tag of a toolstrip container or control.  
        %   It is a string and the default value is ''.
        %   It is optional and writable.
        %
        %   Specify a unique tag in the toolstrip hierarchy if you want to
        %   use the "find" or "get" method to locate the component later.
        Tag
    end
    
    properties (Access = protected)
        Type
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % Tag
        function value = get.Tag(this)
            % GET function for Tag property.
            value = this.getPeerProperty('tag');
        end
        function set.Tag(this, value)
            % SET function for Tag property.
            if ~ischar(value)
                error(message('MATLAB:toolstrip:general:invalidTag'));
            end
            this.setPeerProperty('tag',value);
        end
        % Index
        function value = get.Index(this)
            % GET function for Index property.
            value = [];
            if ~isempty(this.Parent)
                for ct=1:length(this.Parent.Children)
                    if this == this.Parent.Children(ct)
                        value = ct;
                        break;
                    end
                end
            end
        end
        
        %% Overload "delete" method
        function delete(this)
            % Delete this component and all the children.
            %
            % Example:
            %   panel = matlab.ui.internal.toolstrip.Panel
            %   btn = matlab.ui.internal.toolstrip.Button('Submit')
            %   panel.add(btn)
            %   btn.delete
            
            % Remove itself as a child from the parent node if it exists.
            parent = this.Parent;
            if ~isempty(parent) && isvalid(parent)
                siblings = parent.Children;
                k = length(siblings);
                while (k > 0) && (siblings(k) ~= this)
                    k = k-1;
                end
                parent.Children(k) = [];
            end
            % remove all the children from this component.
            % We have to do it from the last child to the first child
            % because the order of the children is kept intact in that way. 
            while ~isempty(this.Children)
                %tree_remove(this, this.Children(end));
                this.Children(end).Parent = [];
                this.Children(end) = [];
            end
            % delete peer node
            this.destroyPeer();
        end
        
    end
    
    methods (Access = protected)
        
        %% get initial properties
        function properties = getDefaultWidgetProperties(this)
            % usually overload by sub-classes
            properties = struct('tag','');
        end
        
        function properties = getCustomWidgetProperties(this, properties, varargin)
            % no op by default.  Overload if necessary.
        end
        
        function OK = isChild(this, obj)
            % check whether obj is a child of this object
            OK = false;
            for ct=1:length(this.Children)
                if obj == this.Children(ct)
                    OK = true;
                    break;
                end
            end
        end
        
    end
    
    methods (Hidden)
        
        function peer = getPeer(this)
            peer = this.Peer;
        end
        
        function id = getId(this)
            id  = char(this.getPeer().getId());
        end
        
        function type = getType(this)
            type = this.Type;
        end
        
    end
    
end

