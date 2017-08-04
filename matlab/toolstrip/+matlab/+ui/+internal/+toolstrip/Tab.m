classdef Tab < matlab.ui.internal.toolstrip.base.Container & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic
    % Layout Container
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Tab.Tab">Tab</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title.Title">Title</a>    
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Tab.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Tab.addSection">addSection</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.TabGroup, matlab.ui.internal.toolstrip.Section
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.

    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Tab(varargin)
            % Constructor "Tab": 
            %
            %   Create a tab.
            %
            %   Examples:
            %       tab1 = matlab.ui.internal.toolstrip.Tab('title1'); 

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Tab',varargin{:});
        end
        
        %% Public API: section management
        function add(this, section, varargin)
            % Method "add":
            %
            %   "add(tab, section)": add a section object at the end of the tab.
            %   Example:
            %       tab1 = matlab.ui.internal.toolstrip.Tab('tab1','tab_title1')
            %       section1 = matlab.ui.internal.toolstrip.Section('section1','sec_title1')
            %       tab1.add(section1)
            %
            %   "add(tab, section, index)": insert a section at a specified location in the tab.
            %   Example:
            %       tab1 = matlab.ui.internal.toolstrip.Tab('tab1','tab_title1')
            %       section1 = matlab.ui.internal.toolstrip.Section('section1','sec_title1')
            %       tab1.add(section1)
            %       section2 = matlab.ui.internal.toolstrip.Section('section2','sec_title2')
            %       tab1.add(section2,1) % insert section2 as the first one
            if isa(section, 'matlab.ui.internal.toolstrip.Section')
                add@matlab.ui.internal.toolstrip.base.Container(this, section, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(section), class(this)));
            end
        end
        
        function sec = addSection(this, varargin)
            % Method "addSection":
            %
            %   "sec = addSection(tab, 'sec1')": create a section object at
            %   the end of the tab and returns its handle. 
            %   Example:
            %       tab = matlab.ui.internal.toolstrip.Tab('tab','FOO')
            %       sec = tab.addSection('sec')
            %
            %   "sec = addSection(tab, 'sec1', 'title')": create a section
            %   object at the end of the tab and returns its handle.
            %   Example:
            %       tab = matlab.ui.internal.toolstrip.Tab('tab','FOO')
            %       sec = tab.addSection('sec', 'BAR')
            try
                sec = matlab.ui.internal.toolstrip.Section(varargin{:});
            catch E
                throw(E)
            end
            this.add(sec);
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
        end
        
        function rules = getInputArgumentRules(this)
            rules = getInputArgumentRules@matlab.ui.internal.toolstrip.base.Container(this);
            rules.peerproperties.title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'title'}};
        end
        
    end
    
end

