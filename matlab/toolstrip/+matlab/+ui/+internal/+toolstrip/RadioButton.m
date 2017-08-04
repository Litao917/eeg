classdef RadioButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Radio Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.RadioButton.RadioButton">RadioButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>        
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
    %   <a href="matlab:help matlab.ui.internal.toolstrip.RadioButton.SelectionChanged">SelectionChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ButtonGroup, matlab.ui.internal.toolstrip.Togglebutton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon radio button state is changed in the view.
        SelectionChanged
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = RadioButton(varargin)
            % Constructor "RadioButton": 
            %
            %   Create a radio button.  Use the following syntax:
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       btn = matlab.ui.internal.toolstrip.RadioButton(group)
            %       btn = matlab.ui.internal.toolstrip.RadioButton(group, text)
            %
            %   Example:
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       text1 = 'Red';
            %       btn1 = matlab.ui.internal.toolstrip.RadioButton(group, text1)
            %       text2 = 'Green';
            %       btn2 = matlab.ui.internal.toolstrip.RadioButton(group, text2)
            %       text3 = 'Blue';
            %       btn3 = matlab.ui.internal.toolstrip.RadioButton(group, text3)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('RadioButton', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultSelectedProperties(properties);
            properties = this.getDefaultButtonGroupProperties(properties);
        end

        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.buttonGroupName = struct('type','groupobj','isAction',true);
            rules.input0 = false;
            rules.input1 = {{'buttonGroupName'}};
            rules.input2 = {{'buttonGroupName','text'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Selected');
            this.Action.addProperty('ButtonGroup');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function ActionPropertySetCallback(this, src, data)
            % only fire when the button is selected
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Selected')
                this.notify('SelectionChanged', eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.RadioButton');
        end
        
    end
    
end

