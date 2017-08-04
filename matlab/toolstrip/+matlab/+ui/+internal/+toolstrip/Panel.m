classdef Panel < matlab.ui.internal.toolstrip.base.Container
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.Panel">Panel</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.addColumn">addColumn</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Section, matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Panel()
            % Constructor "Panel": 
            %
            %   Create a panel.
            %
            %   Examples:
            %       panel1 = matlab.ui.internal.toolstrip.Panel;
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Panel');
        end
        
        %% Public API
        function add(this, column, varargin)
            % Method "add":
            %
            %   "add(panel, column)": add a column at the end of the panel.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col = matlab.ui.internal.toolstrip.Column
            %       sec.add(col)
            %
            %   "add(panel, column, index)": insert a column at a specified location in the panel.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col1 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col1)
            %       col2 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col2, 1) % insert col2 as the first one
            if isa(column, 'matlab.ui.internal.toolstrip.Column')
                for ct=1:length(column.Children)
                    if isa(column.Children(ct),'matlab.ui.internal.toolstrip.Panel')
                        error(message('MATLAB:toolstrip:container:invalidPanelInPanel'));
                    end
                end
                add@matlab.ui.internal.toolstrip.base.Container(this, column, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(column), class(this)));
            end
        end
        
        function col = addColumn(this, varargin)
            % Method "addColumn":
            %
            %   "col = addColumn(panel)": create a column object at
            %   the end of the panel and returns its handle. 
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col = tab.addColumn()
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
    
end
