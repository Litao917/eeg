classdef (Abstract) ActionBehavior_Editable < handle
    % Mixin class inherited by TextField and TextArea
    
    % Author(s): Rong Chen
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2013/11/07 20:33:28 $
    
    properties (Dependent, Access = public)
        % Property "Editable": 
        %
        %   Status of the editability of a control.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       textfield = matlab.ui.internal.toolstrip.TextField
        %       textfield.Editable = false
        Editable
    end
    
    methods (Abstract, Access = protected)
        
        getAction(this)        
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % Editable
        function value = get.Editable(this)
            % GET function
            action = this.getAction;
            value = action.Editable;
        end
        function set.Editable(this, value)
            % SET function
            action = this.getAction();
            action.Editable = value;
        end
        
    end
    
    methods (Hidden)
       
        function properties = getDefaultEditableProperties(this, properties)
            properties.editable = true;
        end
        
    end
    
end