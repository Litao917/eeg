classdef Slider < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowButton ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Steps ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged
    % Horizontal Slider
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.Slider">Slider</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Maximum">Maximum</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Minimum">Minimum</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Steps.Steps">Steps</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowButton">ShowButton</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.ValueChanged">ValueChanged</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.ValueChanging">ValueChanging</a>            
    %
    % See also matlab.ui.internal.toolstrip.TextField
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.

    % ----------------------------------------------------------------------------
    events
        % Event sent upon state changes.
        ValueChanged
        % Event sent upon state changes.
        ValueChanging
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Slider(varargin)
            % Constructor "Slider": 
            %
            %   Creates a slider.
            %
            %   Example:
            %       min = -10; max = 10; value = 5;
            %       sld = matlab.ui.internal.toolstrip.Slider();
            %       sld = matlab.ui.internal.toolstrip.Slider(min, max);
            %       sld = matlab.ui.internal.toolstrip.Slider(min, max, value);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('HorizontalSlider',varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultShowButtonProperties(properties);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultValueProperties(properties);
            properties = this.getDefaultStepsProperties(properties);
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.minimum = struct('type','real','isAction',true);
            rules.peerproperties.maximum = struct('type','real','isAction',true);
            rules.peerproperties.value = struct('type','real','isAction',true);
            rules.input0 = true;
            rules.input3 = {{'minimum';'maximum';'value'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Minimum');
            this.Action.addProperty('Maximum');
            this.Action.addProperty('Value');
            this.Action.addProperty('Steps');
            this.Action.addCallbackFcn('ValueChanged');
        end
        
        function ActionPerformedCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(rmfield(data.EventData,'EventType'));
            this.notify('ValueChanged', eventdata);
        end
        
        function ActionPropertySetCallback(this, src, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanging', eventdata);
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.Slider');
        end
        
    end
    
end
