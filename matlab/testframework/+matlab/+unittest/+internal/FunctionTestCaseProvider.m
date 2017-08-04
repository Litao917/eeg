classdef(Hidden) FunctionTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    % FunctionTestCaseProvider is a TestCaseProvider that holds onto a
    % TestCase instance.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    
    properties(SetAccess=immutable)
        TestCase
    end
    
    properties(Dependent, SetAccess=immutable)
        TestClass
        TestParentName
        TestMethod
        TestName
    end
    
    methods
        function provider = FunctionTestCaseProvider(testFcns, varargin)
            
            import matlab.unittest.internal.FunctionTestCaseProvider;
            import matlab.unittest.FunctionTestCase;
            
            if nargin == 0
                % Allow pre-allocation
                return
            end
            
            numElements = numel(testFcns);
            if numElements > 0
                provider(numElements) = FunctionTestCaseProvider;
                testCaseCell = cellfun(@(fcn) FunctionTestCase.fromFunction(fcn, varargin{:}), testFcns, ...
                                       'UniformOutput', false);                
                [provider.TestCase] = testCaseCell{:};
            end
            provider = reshape(provider, size(testFcns));
        end

        function testCase = createTestCaseFromClassPrototype(provider, prototype)
            testCase = copy(provider.TestCase);
            testCase.TestData = prototype.TestData;
        end

        function testClass = get.TestClass(~)
            testClass = ?matlab.unittest.FunctionTestCase;
        end
        function testParentName = get.TestParentName(provider)
            fcnInfo = functions(provider.TestCase.TestFcn);
            testParentName = fcnInfo.parentage{2};
        end
        function testMethod = get.TestMethod(provider)
            testMethod = findobj(provider.TestClass.MethodList, 'Test', true);
        end
        function testMethodName = get.TestName(provider)
            testMethodName = func2str(provider.TestCase.TestFcn);
        end
    end
    
    
end
