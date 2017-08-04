classdef (Abstract) ActionBehavior_PlaceholderText < handle
    % Mixin class inherited by TextField and TextArea
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "PlaceholderText": 
        %
        %   Placeholder text.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       textfield = matlab.ui.internal.toolstrip.TextField
        %       textfield.PlaceholderText = 'first name'
        PlaceholderText
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.PlaceholderText(this)
            % GET function
            action = this.getAction;
            value = action.PlaceholderText;
        end
        function set.PlaceholderText(this, value)
            % SET function
            action = this.getAction();
            action.PlaceholderText = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultPlaceholderProperties(this, properties)
            properties.placeholderText = '';
        end
        
    end
    
end
