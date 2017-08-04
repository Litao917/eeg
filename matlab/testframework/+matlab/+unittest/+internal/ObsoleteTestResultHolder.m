classdef ObsoleteTestResultHolder < handle
    
    % This class exists solely to allow loading of TestCase and Fixture
    % instances saved prior to R2014b. Such instances contain a TestResult_
    % property.
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Transient, Dependent, Access=?matlab.unittest.TestRunner)
        TestResult_
    end
    methods
        function set.TestResult_(~,~)
        end
    end
end