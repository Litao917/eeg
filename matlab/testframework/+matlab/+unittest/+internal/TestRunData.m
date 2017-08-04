classdef TestRunData < handle
    % This class in undocumented.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties
        CurrentIndex = 1;
        TestResult
    end
    
    properties (SetAccess=immutable)
        TestSuite
    end
    
    methods
        function holder = TestRunData(suite, result)
            holder.TestSuite = suite;
            holder.TestResult = result;
        end
    end
end