classdef(Hidden) TestCaseInstanceProvider < matlab.unittest.internal.TestCaseProvider
    % TestCaseInstanceProvider is a TestCaseProvider that holds onto a
    % TestCase instance.
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    
    properties(SetAccess=immutable)
        TestCase
        TestName
    end
    
    properties(Dependent, SetAccess=immutable)
        TestClass
        TestParentName
        TestMethod
    end
    
    methods
        function provider = TestCaseInstanceProvider(testCase, methods)
            
            import matlab.unittest.internal.TestCaseInstanceProvider;
            
            
            if nargin == 0
                return % Allow pre-allocation
            end
            
            provider = TestCaseInstanceProvider.empty;
            numElements = numel(methods);
            if numElements > 0
                provider(numElements) = TestCaseInstanceProvider;
                [provider.TestCase] = deal(testCase);
                [provider.TestName] = methods.Name;
            end
            provider = reshape(provider, size(methods));
            
        end

        function testCase = createTestCaseFromClassPrototype(~, classTestCase)
            testCase = copy(classTestCase);
        end

        function testClass = get.TestClass(provider)
            testClass = metaclass(provider.TestCase);
        end
        function testClassName = get.TestParentName(provider)
            testClassName = class(provider.TestCase);
        end
        function testMethod = get.TestMethod(provider)
            testMethod = findobj(provider.TestClass.MethodList, 'Name', provider.TestName);
        end
    end
    
    
end
