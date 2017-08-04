classdef CheckBox < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Check Box
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.CheckBox.CheckBox">CheckBox</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Selected">Selected</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.SelectionChangedFcn">SelectionChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.CheckBox.SelectionChanged">SelectionChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ToggleButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.

    events
        % Event sent upon check box is selected/unselected in the UI.
        SelectionChanged
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = CheckBox(varargin)
            % Constructor "CheckBox": 
            %
            %   Create a checkbox.
            %
            %   Examples:
            %       text = 'Select'
            %       selected = true;
            %       cbx = matlab.ui.internal.toolstrip.CheckBox;
            %       cbx = matlab.ui.internal.toolstrip.CheckBox(text);
            %       cbx = matlab.ui.internal.toolstrip.CheckBox(text, selected);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('CheckBox', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultSelectedProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.selected = struct('type','logical','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'}};
            rules.input2 = {{'text';'selected'}};
        end
        
        function addActionProperties(this)
            this.Action.addProperty('Text');
            this.Action.addProperty('Selected');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Selected')
                this.notify('SelectionChanged',eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.CheckBox') || isa(control, 'matlab.ui.internal.toolstrip.ListItemWithCheckBox');
        end
        
    end
    
end

