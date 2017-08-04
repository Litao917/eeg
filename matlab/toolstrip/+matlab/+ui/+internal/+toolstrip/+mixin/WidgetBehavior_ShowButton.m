classdef (Abstract) WidgetBehavior_ShowButton < handle
    % Mixin class inherited by Slider
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ShowButton": 
        %
        %   Whether or not showing the arrow buttons of a slider.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider()
        %       slider.ShowButton = false;
        ShowButton
    end
    
    % ----------------------------------------------------------------------------
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowText
        function value = get.ShowButton(this)
            % GET function
            value = this.getPeerProperty('showButton');
        end
        function set.ShowButton(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowButton'))
            end
            this.setPeerProperty('showButton',value);
        end
    end
    
    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)

        function properties = getDefaultShowButtonProperties(this, properties)
            properties.showButton = true;
        end
        
    end
end

