classdef (Abstract) WidgetBehavior_ShowText < handle
    % Mixin class inherited by ListItem, ListItemWithCheckBox, ListItemWithPopup.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ShowText": 
        %
        %   Whether or not showing text.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItem('MATLAB',matlab.ui.internal.toolstrip.Icon.MATLAB_16,'this is a MATLAB icon')
        %       item.ShowText = false;
        ShowText
    end
    
    % ----------------------------------------------------------------------------
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowText
        function value = get.ShowText(this)
            % GET function
            value = this.getPeerProperty('showText');
        end
        function set.ShowText(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowText'))
            end
            this.setPeerProperty('showText',value);
        end
    end
    
    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)

        function properties = getDefaultShowTextProperties(this, properties)
            properties.showText = true;
        end
        
    end
    
end

