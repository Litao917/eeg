classdef SplitButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed
    % Split Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.SplitButton.SplitButton">SplitButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.DynamicPopupFcn">DynamicPopupFcn</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.Popup">Popup</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>   
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed.ButtonPushedFcn">ButtonPushedFcn</a>                
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.addToQuickAccess">addToQuickAccess</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.removeFromQuickAccess">removeFromQuickAccess</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.SplitButton.ButtonPushed">ButtonPushed</a>        
    %
    % To dynamically refresh popup contents before it is displayed, use the "DynamicPopupFcn" property to regenerate the PopupList.
    %
    % See also matlab.ui.internal.toolstrip.PushButton, matlab.ui.internal.toolstrip.DropDownButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    events
        % Event sent upon push button pressed in the view.
        ButtonPushed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = SplitButton(varargin)
            % Constructor "SplitButton": 
            %
            %   Create a split button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       btn = matlab.ui.internal.toolstrip.SplitButton
            %       btn = matlab.ui.internal.toolstrip.SplitButton(text)
            %       btn = matlab.ui.internal.toolstrip.SplitButton(icon)
            %       btn = matlab.ui.internal.toolstrip.SplitButton(text,icon)
            %       popup = matlab.ui.internal.toolstrip.PopupList;
            %       btn.Popup = popup;
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('SplitButton', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultTextOverrideProperties(properties);
            properties = this.getDefaultIconOverrideProperties(properties);
            properties = this.getDefaultDescriptionOverrideProperties(properties);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultIconProperties(properties);            
            properties = this.getDefaultQuickAccessIconProperties(properties);            
            properties = this.getDefaultIsInQuickAccessProperties(properties);            
            properties = this.getDefaultPopupProperties(properties);                        
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.icon = struct('type','iconobj','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'};{'icon'}};
            rules.input2 = {{'text';'icon'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('Popup');
            this.Action.addProperty('QuickAccessIcon');
            this.Action.addProperty('IsInQuickAccess');
            this.Action.addProperty('DynamicPopupFcn');
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function ActionPerformedCallback(this, ~, ~)
            this.notify('ButtonPushed');
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
            result = isa(control, 'matlab.ui.internal.toolstrip.SplitButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.impl.QABSplitButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.DropDownButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.ListItemWithPopup') ...
                || isa(control, 'matlab.ui.internal.toolstrip.PushButton') ...                
                || isa(control, 'matlab.ui.internal.toolstrip.ListItem');
        end
        
    end
    
end
