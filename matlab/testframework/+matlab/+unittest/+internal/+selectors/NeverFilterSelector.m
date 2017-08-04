classdef NeverFilterSelector < matlab.unittest.internal.selectors.Selector
    % NeverFilterSelector - Selector that performs no filtering.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    methods
        function bool = uses(~,~)
            bool = false;
        end
        
        function result = select(~,~)
            result = true;
        end
    end
end