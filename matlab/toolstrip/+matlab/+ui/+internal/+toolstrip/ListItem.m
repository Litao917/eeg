classdef ListItem < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed
    % List Item
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItem.ListItem">ListItem</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>       
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription.ShowDescription">ShowDescription</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon.ShowIcon">ShowIcon</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>     
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed.ItemPushedFcn">ItemPushedFcn</a>                
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItem.ItemPushed">ItemPushed</a>        
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.PushButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    events
        % Event sent upon list item pressed in the view.
        ItemPushed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItem(varargin)
            % Constructor "ListItem": 
            %
            %   Creates a list item
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       desc = 'Open a file'
            %       item = matlab.ui.internal.toolstrip.ListItem();
            %       item = matlab.ui.internal.toolstrip.ListItem(text);
            %       item = matlab.ui.internal.toolstrip.ListItem(text, icon);
            %       item = matlab.ui.internal.toolstrip.ListItem(text, icon, desc);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItem', varargin{:});
        end
        
    end
    
    methods (Access = protected)

        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultShowTextProperties(properties);
            properties = this.getDefaultShowIconProperties(properties);
            properties = this.getDefaultShowDescriptionProperties(properties);
            properties = this.getDefaultTextOverrideProperties(properties);
            properties = this.getDefaultIconOverrideProperties(properties);
            properties = this.getDefaultDescriptionOverrideProperties(properties);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultIconProperties(properties);            
        end
        
        function rules = getInputArgumentRules(this) %#ok<*MANU>
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
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function ActionPerformedCallback(this, ~, ~)
            this.notify('ItemPushed');
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItem') ...
                || isa(control, 'matlab.ui.internal.toolstrip.PushButton');
        end
        
    end
    
end

