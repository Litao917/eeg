classdef Column < matlab.ui.internal.toolstrip.base.Container
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.Column">Column</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.HorizontalAlignment">HorizontalAlignment</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.Width">Width</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.addEmptyControl">addEmptyControl</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Section, matlab.ui.internal.toolstrip.Panel
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% ----------- User-visible properties --------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "HorizontalAlignment": 
        %
        %   The horizontal alignment of all the controls in the column.
        %   It is a string of 'left' (default), 'center' and 'right'.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center')
        HorizontalAlignment        
        % Property "Width": 
        %
        %   The custom width of the column.
        %   It is a positive finite integer in the unit of pixels.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.Column('Width',100)
        Width
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Column(varargin)
            % Constructor "Column": 
            %
            %   Create a column.
            %
            %   Examples:
            %       column = matlab.ui.internal.toolstrip.Column(); 
            %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center'); 
            %       column = matlab.ui.internal.toolstrip.Column('Width',100); 
            %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center','Width',100); 
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Column',varargin{:});
        end
        
        %% Public API
        % HorizontalAlignment
        function value = get.HorizontalAlignment(this)
            % GET function for HorizontalAlignment property.
            value = this.getPeerProperty('horizontalAlignment');
        end
%         function set.HorizontalAlignment(this, value)
%             % SET function for HorizontalAlignment property.
%             if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'alignment')
%                 this.setPeerProperty('horizontalAlignment',lower(value));
%             else
%                 error(message('MATLAB:toolstrip:container:invalidHorizontalAlignment'))
%             end
%         end
        % Width
        function value = get.Width(this)
            % GET function for Width property.
            value = this.getPeerProperty('width');
            if isempty(value)
                value = [];
            end
        end
%         function set.Width(this, value)
%             % SET function for Width property.
%             if isempty(value)
%                 this.setPeerProperty('width','');
%             elseif matlab.ui.internal.toolstrip.base.Utility.validate(value, 'width')
%                 this.setPeerProperty('width',value);
%             else
%                 error(message('MATLAB:toolstrip:container:invalidWidth'))
%             end
%         end
        
        %% Public API
        function add(this, control, varargin)
            % Method "add":
            %
            %   "add(column, control)": add a control at the end of the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn = matlab.ui.internal.toolstrip.Button
            %       col.add(btn)
            %
            %   "add(column, control, index)": insert a control at a specified location in the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn1 = matlab.ui.internal.toolstrip.Button
            %       col.add(btn1)
            %       btn2 = matlab.ui.internal.toolstrip.Button
            %       col.add(btn2, 1) % insert btn2 as the first button
            if isa(control, 'matlab.ui.internal.toolstrip.base.Control')
                ok = ~isa(control, 'matlab.ui.internal.toolstrip.PopupListHeader') && ~isa(control, 'matlab.ui.internal.toolstrip.GalleryItem');
            elseif isa(control, 'matlab.ui.internal.toolstrip.base.Container')
                ok = isa(control, 'matlab.ui.internal.toolstrip.Panel') || isa(control, 'matlab.ui.internal.toolstrip.Gallery');
            else
                ok = isa(control, 'matlab.ui.internal.toolstrip.EmptyControl');
            end
            if ok
                if isa(control, 'matlab.ui.internal.toolstrip.Panel') && isa(this.Parent, 'matlab.ui.internal.toolstrip.Panel')
                    error(message('MATLAB:toolstrip:container:invalidPanelInPanel'));
                elseif length(this.Children)<3
                    add@matlab.ui.internal.toolstrip.base.Container(this, control, varargin{:});
                else
                    error(message('MATLAB:toolstrip:container:maximumControlReachedInColumn'));                    
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(control), class(this)));
            end
        end
        
        function emptycontrol = addEmptyControl(this)
            % Method "addEmptyControl":
            %
            %   "emptycontrol = addEmptyControl(column)": add an empty control filler in the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn1 = matlab.ui.internal.toolstrip.Button('OK')
            %       col.add(btn1)
            %       col.addEmptyControl();
            %       btn2 = matlab.ui.internal.toolstrip.Button('Cancel')
            %       col.add(btn2) % Two horizontal buttons in the same column, occupying row #1 and #3
            emptycontrol = matlab.ui.internal.toolstrip.EmptyControl();
            this.add(emptycontrol);
        end
        
    end
    
    methods (Hidden)
    
        function remove(this, varargin) %#ok<*MANU>
            % Method "remove"
            error(message('MATLAB:toolstrip:container:removeDisabled'))
        end
            
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.horizontalAlignment = 'left';
            properties.width = '';
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            % set optional properties
            ni = nargin-2;
            if rem(ni,2)~=0,
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'horizontalAlignment','width'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'horizontalAlignment'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                        if ok
                            widget_properties.(name) = lower(value);
                        else
                            error(message('MATLAB:toolstrip:container:invalidHorizontalAlignment'))
                        end
                    case 'width'
                        value = varargin{ct+1};
                        if isempty(value)
                            widget_properties.(name) = '';
                        else
                            ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                            if ok
                                widget_properties.(name) = value;
                            else
                                error(message('MATLAB:toolstrip:container:invalidWidth'))
                            end
                        end
                end
            end
        end
        
    end
    
end

