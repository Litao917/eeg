classdef (Abstract) ActionBehavior_StepSize < handle
    % Mixin class inherited by Spinner

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "MinorStepSize": 
        %
        %   The minor step size used when arrow is pressed. It is a real
        %   number and the default value is 1. It is writable.
        %
        %   Example:
        %       spinner = matlab.ui.internal.toolstrip.Spinner();
        %       spinner.MinorStepSize = 0.5;
        MinorStepSize
        % Property "MajorStepSize": 
        %
        %   The major step size used when page up/down key is pressed. It
        %   is a real number and the default value is 10. It is writable.
        %
        %   Example:
        %       spinner = matlab.ui.internal.toolstrip.Spinner();
        %       spinner.MajorStepSize = 5;
        MajorStepSize
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.MinorStepSize(this)
            % GET function for MinorStepSize property.
            action = this.getAction;
            value = action.MinorStepSize;
        end
        function set.MinorStepSize(this, value)
            % SET function for MinorStepSize property.
            action = this.getAction();
            action.MinorStepSize = value;
        end
        function value = get.MajorStepSize(this)
            % GET function for MajorStepSize property.
            action = this.getAction;
            value = action.MajorStepSize;
        end
        function set.MajorStepSize(this, value)
            % SET function for MajorStepSize property.
            action = this.getAction();
            action.MajorStepSize = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultStepSizeProperties(this, properties)
            properties.minorStepSize = 1;
            properties.majorStepSize = 10;
        end
        
    end
    
end
