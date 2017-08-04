classdef ToggleButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Toggle Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleButton.ToggleButton">ToggleButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>     
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Selected">Selected</a>       
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.SelectionChangedFcn">SelectionChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.addToQuickAccess">addToQuickAccess</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.removeFromQuickAccess">removeFromQuickAccess</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleButton.SelectionChanged">SelectionChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ButtonGroup, matlab.ui.internal.toolstrip.Radiobutton, matlab.ui.internal.toolstrip.CheckBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon check box pressed in the view.
        SelectionChanged
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = ToggleButton(varargin)
            % Constructor "ToggleButton": 
            %
            %   Create a toggle button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       btn = matlab.ui.internal.toolstrip.ToggleButton()
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(icon)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, icon)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, group)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(icon, group)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, icon, group)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ToggleButton', varargin{:});
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
            properties = this.getDefaultSelectedProperties(properties);
            properties = this.getDefaultButtonGroupProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.icon = struct('type','iconobj','isAction',true);
            rules.peerproperties.buttonGroupName = struct('type','groupobj','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'};{'icon'};{'buttonGroupName'}};
            rules.input2 = {{'text';'icon'};{'text';'buttonGroupName'};{'icon';'buttonGroupName'}};
            rules.input3 = {{'text';'icon';'buttonGroupName'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('QuickAccessIcon');
            this.Action.addProperty('IsInQuickAccess');
            this.Action.addProperty('Selected');
            this.Action.addProperty('ButtonGroup');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function ActionPropertySetCallback(this, src, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Selected')
                this.notify('SelectionChanged',eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ToggleButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.impl.QABPushButton') ...
                || (isa(control, 'matlab.ui.internal.toolstrip.RadioButton') && ~isempty(this.ButtonGroup)) ...
                || (isa(control, 'matlab.ui.internal.toolstrip.CheckBox') && isempty(this.ButtonGroup)) ...
                || (isa(control, 'matlab.ui.internal.toolstrip.ListItemWithCheckBox') && isempty(this.ButtonGroup));
        end
        
    end
    
end
