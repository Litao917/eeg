classdef TextField < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged
    % Text Field
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextField.TextField">TextField</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable.Editable">Editable</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
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
    % See also matlab.ui.internal.toolstrip.Slider
    
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
        function this = TextField(varargin)
            % Constructor "TextField": 
            %
            %   Create a text field.
            %
            %   Example:
            %       text = '10';
            %       placeholder = 'Enter a number here';
            %       txtfield = matlab.ui.internal.toolstrip.TextField();
            %       txtfield = matlab.ui.internal.toolstrip.TextField(text);
            %       txtfield = matlab.ui.internal.toolstrip.TextField(text,placeholder);
           
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('TextField',varargin{:});
        end
        
    end
    
    methods (Access = protected)

        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultEditableProperties(properties);
            properties = this.getDefaultPlaceholderProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.placeholderText = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'}};
            rules.input2 = {{'text';'placeholderText'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Editable');
            this.Action.addProperty('PlaceholderText');
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
            result = isa(control, 'matlab.ui.internal.toolstrip.TextField');
        end
        
    end
    
end

