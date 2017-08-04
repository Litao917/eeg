classdef (Abstract) WidgetBehavior_TextOverride < handle
    % Mixin class inherited by PushButton, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "TextOverride": 
        %
        %   TextOverride takes a string.  If specified, the string will
        %   override what is available in the Text property.  Unlike the
        %   Text property, the string sepcified here cannot be shared.  The
        %   default value is ''.  It is writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.PushButton;
        %       btn1.Text = 'foo';
        %       btn2 = matlab.ui.internal.toolstrip.PushButton;
        %       btn1.shareWith(btn2);
        %       btn2.TextOverride = 'bar';
        TextOverride
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.TextOverride(this)
            % GET function
            value = this.getPeerProperty('textOverride');
        end
        
        function set.TextOverride(this, value)
            % SET function
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:control:invalidTextOverride'))
            end
            this.setPeerProperty('textOverride',value);
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultTextOverrideProperties(this, properties)
            properties.textOverride = '';
        end
        
    end
    
end
