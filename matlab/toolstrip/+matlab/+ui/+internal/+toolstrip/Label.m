classdef Label < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon
    % Label
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Label.Label">Label</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Icon
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
  
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Label(varargin)
            % Constructor "Label": 
            %
            %   Create a label.
            %
            %   Example:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN;
            %       lbl = matlab.ui.internal.toolstrip.Label
            %       lbl = matlab.ui.internal.toolstrip.Label(icon)
            %       lbl = matlab.ui.internal.toolstrip.Label(text)
            %       lbl = matlab.ui.internal.toolstrip.Label(text, icon)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('Label', varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultIconProperties(properties);            
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.icon = struct('type','iconobj','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'};{'icon'}};
            rules.input2 = {{'text';'icon'};{'icon';'text'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.Label');
        end
        
    end
    
end

