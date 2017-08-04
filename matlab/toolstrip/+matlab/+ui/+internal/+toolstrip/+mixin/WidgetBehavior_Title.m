classdef (Abstract) WidgetBehavior_Title < handle
    % Mixin class inherited by Tab and Section.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Title": 
        %
        %   The title of a tab, a section or a popup list header
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       section1 = matlab.ui.internal.toolstrip.Section('FOO')
        %       section1.Title % returns 'FOO'
        %       section1.Title = 'BAR' % change section title to BAR
        Title
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Title(this)
            % GET function
            value = this.getPeerProperty('title');
        end
        
        function set.Title(this, value)
            % SET function
            if ~ischar(value)
                error(message('MATLAB:toolstrip:container:invalidTitle'))
            end
            this.setPeerProperty('title',value);
        end

    end
    
    methods (Hidden)
       
        function properties = getDefaultTitleProperties(this, properties)
            properties.title = '';
        end
        
    end
        
    
end

