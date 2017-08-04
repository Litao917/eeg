classdef (Sealed) OrSelector < matlab.unittest.internal.selectors.Selector
    % OrSelector - Boolean disjunction of two selectors.
    %   An OrSelector is produced when the "|" operator is used to denote the
    %   disjunction of two selectors.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % FirstSelector - The left selector that is being OR'ed.
        FirstSelector
        
        % SecondSelector - The right selector that is being OR'ed.
        SecondSelector
    end
    
    methods (Access=?matlab.unittest.internal.selectors.Selector)
        function orSelector = OrSelector(firstSelector, secondSelector)
            validateattributes(firstSelector, ...
                {'matlab.unittest.internal.selectors.Selector'}, ...
                {'scalar'}, '', 'firstSelector');
            validateattributes(secondSelector, ...
                {'matlab.unittest.internal.selectors.Selector'}, ...
                {'scalar'}, '', 'secondSelector');
            
            orSelector.FirstSelector = firstSelector;
            orSelector.SecondSelector = secondSelector;
        end
    end
    
    methods (Hidden)
        function bool = uses(selector, attributeClass)
            bool = selector.FirstSelector.uses(attributeClass) || ...
                selector.SecondSelector.uses(attributeClass);
        end
        
        function result = select(selector, attributes)
            result = selector.FirstSelector.select(attributes) || ...
                selector.SecondSelector.select(attributes);
        end
    end
end

% LocalWords:  OR'ed
