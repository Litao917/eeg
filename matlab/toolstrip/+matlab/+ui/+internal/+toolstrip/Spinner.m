classdef Spinner < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged
    % Numerical Spinner
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.Spinner">Spinner</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Maximum">Maximum</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Minimum">Minimum</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize.MinorStepSize">MinorStepSize</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize.MajorStepSize">MajorStepSize</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.ValueChanged">ValueChanged</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.ValueChanging">ValueChanging</a>            
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
        function this = Spinner(varargin)
            % Constructor "Spinner": 
            %
            %   Creates a spinner.
            %
            %   Example:
            %       min = -10; max = 10; value = 5;
            %       sld = matlab.ui.internal.toolstrip.Spinner();
            %       sld = matlab.ui.internal.toolstrip.Spinner(min, max);
            %       sld = matlab.ui.internal.toolstrip.Spinner(min, max, value);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('Spinner',varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultValueProperties(properties);
            properties = this.getDefaultStepSizeProperties(properties);
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
            this.Action.addProperty('MinorStepSize');
            this.Action.addProperty('MajorStepSize');
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
            result = isa(control, 'matlab.ui.internal.toolstrip.Spinner');
        end
        
    end
    
end
