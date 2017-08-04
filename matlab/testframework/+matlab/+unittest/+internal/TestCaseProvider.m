classdef(Hidden) TestCaseProvider
    % Class to help abstract different ways to provide testCases. This is
    % used when constructing TestSuite, some of which have a TestCase
    % prototype and some of which only have the TestCase meta classes.
    
    %  Copyright 2012 The MathWorks, Inc.
    
    
    properties(Abstract, SetAccess=immutable)
        TestCase
        TestClass
        TestParentName
        TestMethod
        TestName
    end

    methods(Abstract)
        testCase = createTestCaseFromClassPrototype(classTestCase);
    end
    
end
