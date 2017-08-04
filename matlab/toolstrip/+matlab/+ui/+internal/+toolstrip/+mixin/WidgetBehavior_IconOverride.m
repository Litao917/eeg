classdef (Abstract) WidgetBehavior_IconOverride < handle
    % Mixin class inherited by PushButton, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "IconOverride": 
        %
        %   IconOverride takes a matlab.ui.internal.toolstrip.Icon object.
        %   If specified, the icon will override what is available in the
        %   Icon property.  Unlike the Icon property, the icon sepcified
        %   here cannot be shared.  The default value is [].  It is
        %   writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.PushButton
        %       btn1.Icon = matlab.ui.internal.toolstrip.Icon('foo.jpg')
        %       btn2 = matlab.ui.internal.toolstrip.PushButton
        %       btn1.shareWith(btn2);
        %       btn2.IconOverride = matlab.ui.internal.toolstrip.Icon('bar.jpg')
        IconOverride
    end
    
    properties (Access = private)
        IconOverride_
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.IconOverride(this)
            % GET function
            value = this.IconOverride_;
        end
        
        function set.IconOverride(this, value)
            % SET function
            if isempty(value)
                this.IconOverride_ = [];
                this.setPeerProperty('iconOverride','');
                this.setPeerProperty('iconClassOverride','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.IconOverride_ = value;
                if isCSS(value)
                    iconclass = value.getIconClass();
                    this.setPeerProperty('iconClassOverride',iconclass);
                    this.setPeerProperty('iconOverride','');
                else
                    url = value.getBase64URL();
                    this.setPeerProperty('iconClassOverride','');
                    this.setPeerProperty('iconOverride',url);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIconOverride'))
            end
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultIconOverrideProperties(this, properties)
            properties.iconOverride = '';
        end
        
    end
    
end

