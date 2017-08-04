classdef (Abstract) ActionBehavior_Steps < handle
    % Mixin class inherited by Slider

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Steps": 
        %
        %   The number of steps between the minimum and maximum values. It
        %   is an integer and the default value is 100. It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider
        %       slider.Steps = 10
        Steps
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Steps(this)
            % GET function for Steps property.
            action = this.getAction;
            value = action.Steps;
        end
        function set.Steps(this, value)
            % SET function for Steps property.
            action = this.getAction();
            action.Steps = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultStepsProperties(this, properties)
            properties.steps = 100;
        end
        
    end
    
end
