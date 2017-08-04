classdef Section < matlab.ui.internal.toolstrip.base.Container & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.Section">Section</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.CollapsePriority">CollapsePriority</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title.Title">Title</a>        
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.addColumn">addColumn</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Tab, matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "CollapsePriority": 
        %
        %   The section with highest priority collapse last in the tab.
        %   It is an integer and the default value is 0.
        %   It is writable.
        %
        %   Example:
        %       section1 = matlab.ui.internal.toolstrip.Section('FOO')
        %       section1.CollapsePriority = 10;
        CollapsePriority
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Section(varargin)
            % Constructor "Section": 
            %
            %   Create a section.
            %
            %   Examples:
            %       section1 = matlab.ui.internal.toolstrip.Section('title1'); 

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Section',varargin{:});
        end
        
        %% Public API: Get/Set
        % CollapsePriority
        function value = get.CollapsePriority(this)
            % GET function for CollapsePriority property.
            value = this.getPeerProperty('collapsePriority');
        end
        function set.CollapsePriority(this, value)
            % SET function for Title property.
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'collapse_priority')
                this.setPeerProperty('collapsePriority',value);
            else
                error(message('MATLAB:toolstrip:container:invalidCollapsePriority'))
            end
        end
        
        %% Public API: control management
        function add(this, column, varargin)
            % Method "add":
            %
            %   "add(section, column)": add a column at the end of the section.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('title')
            %       col = matlab.ui.internal.toolstrip.Column
            %       sec.add(col)
            %
            %   "add(section, column, index)": insert a column at a specified location in the section.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('title')
            %       col1 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col1)
            %       col2 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col2, 1) % insert col2 as the first one
            if isa(column, 'matlab.ui.internal.toolstrip.Column')
                add@matlab.ui.internal.toolstrip.base.Container(this, column, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(column), class(this)));
            end
        end
        
        function col = addColumn(this, varargin)
            % Method "addColumn":
            %
            %   "col = addColumn(section)": create a column object at
            %   the end of the section and returns its handle. 
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('FOO')
            %       col = tab.addColumn()
            %       col = tab.addColumn('HorizontalAlignment', 'center')
            %       col = tab.addColumn('Width', 100)
            col = matlab.ui.internal.toolstrip.Column(varargin{:});
            this.add(col);
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
            properties = this.getDefaultTitleProperties(properties);
            properties = this.getDefaultMnemonicProperties(properties);
            properties.collapsePriority = 0;
        end
        
        function rules = getInputArgumentRules(this)
            rules = getInputArgumentRules@matlab.ui.internal.toolstrip.base.Container(this);
            rules.peerproperties.title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'title'}};
        end
        
    end
    
end

