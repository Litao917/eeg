classdef (Abstract) CallbackFcn_ItemSelected < handle
    % Mixin class inherited by List and ComboBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ItemSelectedFcn": 
        %
        %   This callback function executes when an item is selected.
        %
        %   Valid callback types are:
        %       * a function handle
        %       * a string
        %       * a 1xN cell array where the first element is either a function handle or a string
        %       * [], representing no callback
        %
        %   Example:
        %       list.ItemSelectedFcn = @(x,y) disp('Callback fired!');
        ItemSelectedFcn
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.ItemSelectedFcn(this)
            % GET function
            action = this.getAction;
            value = action.ItemSelectedFcn;
        end
        function set.ItemSelectedFcn(this, value)
            % SET function
            action = this.getAction();
            action.ItemSelectedFcn = value;
        end
        
    end
    
end
