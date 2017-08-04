classdef (Abstract) CallbackFcn_TextChanged < handle
    % Mixin class inherited by TextField and TextArea
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "TextChangedFcn": 
        %
        %   This callback function executes when the enter key is pressed
        %   or the shortcut key is activated.
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       textfield.TextChangedFcn = @(x,y) disp('Callback fired!');
        TextChangedFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.TextChangedFcn(this)
            % GET function
            action = this.getAction;
            value = action.TextChangedFcn;
        end
        function set.TextChangedFcn(this, value)
            % SET function
            action = this.getAction();
            action.TextChangedFcn = value;
        end
        
    end
    
end
