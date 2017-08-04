classdef (Abstract) ActionBehavior_Value < handle
    % Mixin class inherited by Slider and Spinner

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Minimum": 
        %
        %   Slider minimum value.
        %   It is a real number and the default value is 0.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Minimum = -10
        Minimum
        % Property "Maximum": 
        %
        %   Slider maximum value.
        %   It is a real number and the default value is 100.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Maximum = 10
        Maximum
    end
    
    properties (Dependent, Access = public)
        % Property "Value": 
        %
        %   It is a real number and the default value is 50.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider(0,100,50)
        %       slider.Value = 70
        Value
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Value(this)
            % GET function for Value property.
            action = this.getAction;
            value = action.Value;
        end
        function set.Value(this, value)
            % SET function for Value property.
            action = this.getAction();
            action.Value = value;
        end
        
        function value = get.Minimum(this)
            % GET function for Minimum property.
            action = this.getAction;
            value = action.Minimum;
        end
        function set.Minimum(this, value)
            % SET function for Minimum property.
            action = this.getAction();
            action.Minimum = value;
        end
        
        function value = get.Maximum(this)
            % GET function for Maximum property.
            action = this.getAction;
            value = action.Maximum;
        end
        function set.Maximum(this, value)
            % SET function for Maximum property.
            action = this.getAction();
            action.Maximum = value;
        end
    end
    
    methods (Hidden)
       
        function properties = getDefaultValueProperties(this, properties)
            properties.minimum = 0;
            properties.maximum = 100;
            properties.value = 50;
        end
        
    end
    
end
