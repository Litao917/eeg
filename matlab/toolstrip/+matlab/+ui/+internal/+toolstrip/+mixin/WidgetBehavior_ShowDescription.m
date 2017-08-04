classdef (Abstract) WidgetBehavior_ShowDescription < handle
    % Mixin class inherited by ListItem, ListItemWithCheckBox, ListItemWithPopup.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ShowDescription": 
        %
        %   Whether or not showing description.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItem('MATLAB',matlab.ui.internal.toolstrip.Icon.MATLAB_16,'this is a MATLAB icon')
        %       item.ShowDescription = false;
        ShowDescription
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowDescription
        function value = get.ShowDescription(this)
            % GET function
            value = this.getPeerProperty('showDescription');
        end
        function set.ShowDescription(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowDescription'))
            end
            this.setPeerProperty('showDescription',value);
        end
    end
    
    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)

        function properties = getDefaultShowDescriptionProperties(this, properties)
            properties.showDescription = true;
        end
        
    end
    
end

