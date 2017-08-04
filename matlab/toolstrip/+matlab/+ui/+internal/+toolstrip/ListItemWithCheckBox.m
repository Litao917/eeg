classdef ListItemWithCheckBox < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % ListItem with CheckBox
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithCheckBox.ListItemWithCheckBox">ListItemWithCheckBox</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Selected">Selected</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription.ShowDescription">ShowDescription</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.SelectionChangedFcn">SelectionChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithCheckBox.SelectionChanged">SelectionChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.CheckBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon check box pressed in the view.
        SelectionChanged
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithCheckBox(varargin)
            % Constructor "ListItemWithCheckBox": 
            %
            %   Creates a list item with check box
            %
            %   Examples:
            %       text = 'Open';
            %       desc = 'Open a file'
            %       help = 'help'
            %       item = matlab.ui.internal.toolstrip.ListItemWithCheckBox(text);
            %       item = matlab.ui.internal.toolstrip.ListItemWithCheckBox(text, desc);
            %       item = matlab.ui.internal.toolstrip.ListItemWithCheckBox(text, desc, selected);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithCheckBox', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultShowTextProperties(properties);
            properties = this.getDefaultShowDescriptionProperties(properties);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultSelectedProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.description = struct('type','string','isAction',true);
            rules.peerproperties.selected = struct('type','logical','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'}};
            rules.input2 = {{'text';'description'},{'text';'selected'}};
            rules.input3 = {{'text';'description';'selected'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Selected');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function ActionPropertySetCallback(this, src, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Selected')
                this.notify('SelectionChanged',eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithCheckBox') || isa(control, 'matlab.ui.internal.toolstrip.CheckBox');
        end
        
    end
    
end
