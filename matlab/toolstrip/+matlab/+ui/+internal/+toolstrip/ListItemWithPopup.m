classdef ListItemWithPopup < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup
    % ListItem With PopupList
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithPopup.ListItemWithPopup">ListItemWithPopup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.DynamicPopupFcn">DynamicPopupFcn</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.Popup">Popup</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription.ShowDescription">ShowDescription</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon.ShowIcon">ShowIcon</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   N/A
    %
    % To dynamically refresh popup contents before it is displayed, use the "DynamicPopupFcn" property to regenerate the PopupList.
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.DropDownButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithPopup(varargin)
            % Constructor "ListItem": 
            %
            %   Creates a list item used in a popup list
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       desc = 'Open a file'
            %       help = 'help'
            %       item = matlab.ui.internal.toolstrip.ListItemWithPopup(text);
            %       item = matlab.ui.internal.toolstrip.ListItemWithPopup(text, icon);
            %       item = matlab.ui.internal.toolstrip.ListItemWithPopup(text, icon, desc);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithPopup', varargin{:});
        end
        
    end
    
    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)

        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultShowTextProperties(properties);
            properties = this.getDefaultShowIconProperties(properties);
            properties = this.getDefaultShowDescriptionProperties(properties);
            properties = this.getDefaultTextOverrideProperties(properties);
            properties = this.getDefaultIconOverrideProperties(properties);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultIconProperties(properties);            
            properties = this.getDefaultPopupProperties(properties);                        
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.icon = struct('type','iconobj','isAction',true);
            rules.peerproperties.description = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'}};
            rules.input2 = {{'text';'icon'};{'text';'description'}};
            rules.input3 = {{'text';'icon';'description'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('Popup');
            this.Action.addProperty('DynamicPopupFcn');
        end
        
        function PeerEventCallback(this,src,data)
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'DropDownPerformed')
                if ~isempty(this.DynamicPopupFcn)
                    this.Popup = matlab.ui.internal.toolstrip.base.Utility.executeCallback(this.DynamicPopupFcn, this, eventdata);
                end
                this.dispatchEvent(struct('eventType','showPopup','popupId',this.Popup.getId()));
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithPopup') || isa(control, 'matlab.ui.internal.toolstrip.DropDownButton');
        end
        
    end
    
end
