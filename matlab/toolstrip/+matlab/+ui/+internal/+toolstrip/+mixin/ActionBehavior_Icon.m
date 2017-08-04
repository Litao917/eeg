classdef (Abstract) ActionBehavior_Icon < handle
    % Mixin class inherited by PushButton, DropDownButton, SplitButton,
    % ToggleButton, Label, ListItem, ListItemWIthPopupList
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "Icon": 
        %
        %   Icon used in a control. It is a matlab.ui.internal.toolstrip.Icon object
        %   and the default value is []. It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.PushButton
        %       btn.Icon = matlab.ui.internal.toolstrip.Icon.MATLAB
        Icon
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Icon(this)
            % GET function
            action = this.getAction;
            value = action.Icon;
        end
        
        function set.Icon(this, value)
            % SET function
            action = this.getAction();
            action.Icon = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultIconProperties(this, properties)
            % in the peer node, base64 url string is stored.
            properties.icon = '';
            properties.iconClass = '';
        end
        
    end
    
end

