classdef PushButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed
    % Push Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PushButton.PushButton">PushButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
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
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PushButton.ButtonPushed">ButtonPushed</a>        
    %
    % See also matlab.ui.internal.toolstrip.ListItem, matlab.ui.internal.toolstrip.SplitButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon push button pressed in the view.
        ButtonPushed
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PushButton(varargin)
            % Constructor "Button": 
            %
            %   Create a push button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       btn = matlab.ui.internal.toolstrip.Button
            %       btn = matlab.ui.internal.toolstrip.Button(text)
            %       btn = matlab.ui.internal.toolstrip.Button(icon)
            %       btn = matlab.ui.internal.toolstrip.Button(text,icon)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('PushButton', varargin{:});
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
            this.Action.addProperty('QuickAccessIcon');
            this.Action.addProperty('IsInQuickAccess');
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function ActionPerformedCallback(this, ~, ~)
            this.notify('ButtonPushed');
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.PushButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.impl.QABPushButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.ListItem');
        end
        
    end
    
end
