classdef (Abstract) ActionBehavior_QuickAccessIcon < handle
    % Mixin class inherited by PushButton, DropDownButton, SplitButton,
    % ToggleButton, ListItem and ListItemWithPopup
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "QuickAccessIcon": 
        %
        %   QuickAccessIcon used in a control. It is a
        %   matlab.ui.internal.toolstrip.Icon object and the default value
        %   is []. It is writable. 
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.PushButton
        %       btn.QuickAccessIcon = matlab.ui.internal.toolstrip.Icon.MATLAB_16
        QuickAccessIcon
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.QuickAccessIcon(this)
            % GET function
            action = this.getAction;
            value = action.QuickAccessIcon;
        end
        
        function set.QuickAccessIcon(this, value)
            % SET function
            action = this.getAction();
            action.QuickAccessIcon = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultQuickAccessIconProperties(this, properties)
            properties.quickAccessIcon = '';
            properties.quickAccessIconClass = '';
        end
        
    end
    
end

