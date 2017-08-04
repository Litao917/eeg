classdef (Abstract) WidgetBehavior_DescriptionOverride < handle
    % Mixin class inherited by PushButton, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "DescriptionOverride": 
        %
        %   DescriptionOverride takes a string.  If specified, the string will
        %   override what is available in the Description property.  Unlike the
        %   Description property, the string sepcified here cannot be shared.  The
        %   default value is ''.  It is writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.PushButton;
        %       btn1.Description = 'foo';
        %       btn2 = matlab.ui.internal.toolstrip.PushButton;
        %       btn1.shareWith(btn2);
        %       btn2.DescriptionOverride = 'bar';
        DescriptionOverride
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.DescriptionOverride(this)
            % GET function
            value = this.getPeerProperty('descriptionOverride');
        end
        
        function set.DescriptionOverride(this, value)
            % SET function
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:control:invalidDescriptionOverride'))
            end
            this.setPeerProperty('descriptionOverride',value);
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultDescriptionOverrideProperties(this, properties)
            properties.descriptionOverride = '';
        end
        
    end
    
end

