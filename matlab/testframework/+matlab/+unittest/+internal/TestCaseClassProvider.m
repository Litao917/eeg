classdef(Hidden) TestCaseClassProvider < matlab.unittest.internal.TestCaseProvider
    % TestCaseClassProvider is a TestCaseProvider that holds onto a
    % TestCase class.
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    
    properties(Dependent, SetAccess=immutable)
        TestCase
        TestClass
        TestMethod
    end
    
    properties(SetAccess=immutable)
        TestParentName
        TestName
    end
    
    
    methods
        function provider = TestCaseClassProvider(testClass, methods)
            
            
            import matlab.unittest.internal.TestCaseClassProvider;
            
            if nargin == 0
                return % Allow pre-allocation
            end
            
            provider = TestCaseClassProvider.empty;
            numElements = numel(methods);
            if numElements > 0
                provider(numElements) = TestCaseClassProvider;
                [provider.TestParentName] = deal(testClass.Name);
                [provider.TestName] = methods.Name;
            end
            provider = reshape(provider, size(methods));
            
        end
        
        
        function testCase = createTestCaseFromClassPrototype(~, classTestCase)
            testCase = copy(classTestCase);
        end

        function testCase = get.TestCase(provider)
            % Construct a new TestCase from the class.
            constructTestCase = str2func(provider.TestParentName);
            testCase = constructTestCase();
        end
        function testClass = get.TestClass(provider)
            testClass = meta.class.fromName(provider.TestParentName);
        end
        function testMethod = get.TestMethod(provider)
            testMethod = findobj(provider.TestClass.MethodList, 'Name', provider.TestName);
        end
    end
    
    
end

% LocalWords:  func
