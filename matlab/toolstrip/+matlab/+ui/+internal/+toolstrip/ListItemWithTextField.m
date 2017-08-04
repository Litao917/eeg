classdef ListItemWithTextField < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Label ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged
    % ListItem with TextField
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithTextField.ListItemWithTextField">ListItemWithTextField</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable.Editable">Editable</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Label.Label">Label</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText.PlaceholderText">PlaceholderText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged.TextChangedFcn">TextChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.TextChanged">TextChanged</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.TextCancelled">TextCancelled</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.FocusGained">FocusGained</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.FocusLost">FocusLost</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.Typing">Typing</a>
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.CheckBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    events
        % Combination of the above two event.
        TextChanged
        % Event sent when text is changed in the view.
        TextCancelled
        FocusGained
        FocusLost
        Typing
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithTextField(varargin)
            % Constructor "ListItemWithTextField": 
            %
            %   Creates a list item with check box
            %
            %   Examples:
            %       lbl = 'Number of lines:';
            %       txt = '10';
            %       placeholder = 'Enter an integer here';
            %       item = matlab.ui.internal.toolstrip.ListItemWithTextField(lbl);
            %       item = matlab.ui.internal.toolstrip.ListItemWithTextField(lbl, text);
            %       item = matlab.ui.internal.toolstrip.ListItemWithTextField(lbl, text, placeholder);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithTextField', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultLabelProperties(properties);
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultPlaceholderProperties(properties);
            properties = this.getDefaultEditableProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.label = struct('type','string','isAction',true);
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.placeholderText = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'label'}};
            rules.input2 = {{'label';'text'}};
            rules.input3 = {{'label';'text';'placeholderText'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Label');
            this.Action.addProperty('Text');
            this.Action.addProperty('PlaceholderText');
            this.Action.addProperty('Editable');
            this.Action.addCallbackFcn('TextChanged');
        end
        
        function ActionPerformedCallback(this, src, data)
            type = data.EventData.EventType;
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(rmfield(data.EventData,'EventType'));
            this.notify(type, eventdata);
        end
        
        function ActionPropertySetCallback(this, src, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Text')
                this.notify('TextChanged',eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithTextField');
        end
        
    end
    
end
