classdef (Abstract) ActionBehavior_Label < handle
    % Mixin class inherited by ListItemWithTextField

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "Label": 
        %
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItemWithTextField
        %       item.Label = 'Degrees:'
        Label
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Label(this)
            % GET function
            action = this.getAction;
            value = action.Label;
        end
        function set.Label(this, value)
            % SET function
            action = this.getAction();
            action.Label = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultLabelProperties(this, properties)
            properties.label = '';
        end
        
    end
    
end
