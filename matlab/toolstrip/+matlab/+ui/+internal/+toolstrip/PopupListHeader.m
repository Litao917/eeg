classdef PopupListHeader < matlab.ui.internal.toolstrip.base.Component & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title
    % Popup List Header
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListHeader.PopupListHeader">PopupListHeader</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title.Title">Title</a>        
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.PopupList
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PopupListHeader(varargin)
            % Constructor "PopupListHeader": 
            %
            %   Creates a popup header in a popup list
            %
            %   Examples:
            %       header = matlab.ui.internal.toolstrip.base.PopupListHeader('Simulink Products');

            % super
            this = this@matlab.ui.internal.toolstrip.base.Component();
            % set type
            this.Type = 'PopupListHeader';
            % default
            properties = this.getDefaultWidgetProperties();
            % custom
            properties = this.getCustomWidgetProperties(properties, varargin{:});
            % create peer node
            this.createPeer(properties);
        end
        
    end
    
    methods (Access = protected)
        
        %% get initial properties
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Component(this);
            properties = this.getDefaultTitleProperties(properties);
        end
        
        function properties = getCustomWidgetProperties(this, properties, varargin)
            if nargin>2
                rules = this.getInputArgumentRules();
                [~, properties] = matlab.ui.internal.toolstrip.base.Utility.updateProperties(rules, struct, properties, varargin{:}); 
            end
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'title'}};
        end
        
    end
    
end
