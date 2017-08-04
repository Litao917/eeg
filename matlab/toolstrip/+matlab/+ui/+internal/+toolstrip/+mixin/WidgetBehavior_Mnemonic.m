classdef (Abstract) WidgetBehavior_Mnemonic < handle
    % Mixin class inherited by all the controls and Tab and Section
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Mnemonic": 
        %
        %   The mnemonic key of a control or tab or section.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button('Submit')
        %       btn.Mnemonic = 'S'
        Mnemonic
    end
    
    methods (Abstract, Access = protected)
        
        getPeerProperty(this)
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % Mnemonic
        function value = get.Mnemonic(this)
            % GET function
            value = this.getPeerProperty('mnemonic');
        end
        function set.Mnemonic(this, value)
            % SET function
            if ~ischar(value) || ~all(isletter(value))
                error(message('MATLAB:toolstrip:control:invalidMnemonic'))
            end
            this.setPeerProperty('mnemonic',value);
        end

    end
    
    methods (Hidden)
       
        function properties = getDefaultMnemonicProperties(this, properties)
            properties.mnemonic = '';
        end
        
    end
        
    
end

