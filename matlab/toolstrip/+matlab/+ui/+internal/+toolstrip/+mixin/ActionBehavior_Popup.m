classdef (Abstract) ActionBehavior_Popup < handle
    % Mixin class inherited by DropDown, SplitButton and ListItemWithPopup
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "Popup": 
        %
        %   The popup list that is displayed as a drop down or a sub-popup.
        %   It is a matlab.ui.internal.toolstrip.PopupList object and the default
        %   value is []. It is writable.
        %
        %   Example:
        %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.MATLAB)
        %       item2 = matlab.ui.internal.toolstrip.ListItem('Delete Plot',matlab.ui.internal.toolstrip.Icon.SIMULINK)
        %       popup = matlab.ui.internal.toolstrip.PopupList()
        %       popup.add(item1)
        %       popup.add(item2)
        %       btn = matlab.ui.internal.toolstrip.SplitButton('Plot')
        %       btn.Popup = popup;
        Popup
        % Property "DynamicPopupFcn": 
        %
        %   This property stores a function handle that generates a popup.
        %   It is called automatically when the drop down action occurs.
        %   The function handle must return a PopupList object.
        %
        %   Valid types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no function handle
        %
        %   Example:
        %       btn.DynamicPopupFcn = @buildPopup;
        %
        %       function popup = buildPopup(src, data)
        %           popup = PopupList();
        %           popup.add(ListItem(why));
        %       end
        DynamicPopupFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % Popup
        function value = get.Popup(this)
            % GET function
            action = this.getAction();
            value = action.Popup;
        end
        function set.Popup(this, value)
            % SET function
            action = this.getAction();
            action.Popup = value;
        end
        % DynamicPopupFcn
        function value = get.DynamicPopupFcn(this)
            % GET function
            action = this.getAction();
            value = action.DynamicPopupFcn;
        end
        function set.DynamicPopupFcn(this, value)
            % SET function
            action = this.getAction();
            action.DynamicPopupFcn = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultPopupProperties(this, properties)
            % in the peer node, popup id is stored.
            properties.popupId = '';
        end
        
    end
    
end
