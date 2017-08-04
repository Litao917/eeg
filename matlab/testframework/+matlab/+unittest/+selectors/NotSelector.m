classdef (Sealed) NotSelector < matlab.unittest.internal.selectors.Selector
    % NotSelector - Boolean complement of a selector.
    %   A NotSelector is produced when the "~" operator is used to denote the
    %   complement of a selector.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Selector - The selector that is being complemented.
        Selector
    end
    
    methods (Access=?matlab.unittest.internal.selectors.Selector)
        function notSelector = NotSelector(selector)
            validateattributes(selector, ...
                {'matlab.unittest.internal.selectors.Selector'}, ...
                {'scalar'}, '', 'selector');
            
            notSelector.Selector = selector;
        end
    end
    
    methods (Hidden)
        function bool = uses(selector, attributeClass)
            bool = selector.Selector.uses(attributeClass);
        end
        
        function result = select(selector, attributes)
            result = ~selector.Selector.select(attributes);
        end
    end
end