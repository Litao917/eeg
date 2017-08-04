classdef (Sealed) AndSelector < matlab.unittest.internal.selectors.Selector
    % AndSelector - Boolean conjunction of two selectors.
    %   An AndSelector is produced when the "&" operator is used to denote the
    %   conjunction of two selectors.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % FirstSelector - The left selector that is being AND'ed.
        FirstSelector
        
        % SecondSelector - The right selector that is being AND'ed.
        SecondSelector
    end
    
    methods (Access=?matlab.unittest.internal.selectors.Selector)
        function andSelector = AndSelector(firstSelector, secondSelector)
            validateattributes(firstSelector, ...
                {'matlab.unittest.internal.selectors.Selector'}, ...
                {'scalar'}, '', 'firstSelector');
            validateattributes(secondSelector, ...
                {'matlab.unittest.internal.selectors.Selector'}, ...
                {'scalar'}, '', 'secondSelector');
            
            andSelector.FirstSelector = firstSelector;
            andSelector.SecondSelector = secondSelector;
        end
    end
    
    methods (Hidden)
        function bool = uses(selector, attributeClass)
            bool = selector.FirstSelector.uses(attributeClass) || ...
                selector.SecondSelector.uses(attributeClass);
        end
        
        function result = select(selector, attributes)
            result = selector.FirstSelector.select(attributes) && ...
                selector.SecondSelector.select(attributes);
        end
    end
end

% LocalWords:  AND'ed
