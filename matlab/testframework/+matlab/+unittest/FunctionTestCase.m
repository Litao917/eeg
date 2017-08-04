classdef(Sealed) FunctionTestCase < matlab.unittest.TestCase
    % FunctionTestCase - TestCase for use in function based tests
    %
    %   The matlab.unittest.FunctionTestCase is the means by which
    %   qualification is performed in tests written using the functiontests
    %   function. For each test function, MATLAB creates a FunctionTestCase
    %   and passes it into the test function. This allows test writers to
    %   use the qualification functions (verifications, assertions,
    %   assumptions, and fatal assertions) to ensure their MATLAB code
    %   operates correctly.
    %
    %   See also: functiontests, runtests
    
    
    
    
    % Copyright 2013 The MathWorks, Inc.

    properties
        % TestData - Property used to pass data between test functions.
        %
        %   The TestData property can be utilized by tests to pass data
        %   between fixture setup, test, and fixture teardown functions for
        %   tests created using functiontests. The default value of this
        %   property is a scalar structure with no fields. This allows a
        %   test writer to easily add test data as additional fields on
        %   this structure. However, the test author can reassign this
        %   value to any valid MATLAB value.
        TestData = struct;
    end

    
    properties(Hidden, SetAccess=private)
        TestFcn
        SetupFcn
        TeardownFcn
        SetupOnceFcn
        TeardownOnceFcn
    end
    
    properties(Constant, Access=private)
        FromFunctionParser = createFromFunctionParser;
    end
    
    
    methods(Hidden, Static)
        function testCase = fromFunction(fcn, varargin)
            import matlab.unittest.FunctionTestCase;
            
            
            testCase = FunctionTestCase;
            parser = testCase.FromFunctionParser;
            parser.parse(fcn, varargin{:});
            testCase.TestFcn = parser.Results.TestFcn;
            testCase.SetupFcn = parser.Results.SetupFcn;
            testCase.TeardownFcn = parser.Results.TeardownFcn;
            testCase.SetupOnceFcn = parser.Results.SetupOnceFcn;
            testCase.TeardownOnceFcn = parser.Results.TeardownOnceFcn;
        end
    end
    
    
    
    methods(Hidden, TestClassSetup)
        function setupTestClass(testCase)
            testCase.SetupOnceFcn(testCase);
        end
    end
    
    methods(Hidden, TestClassTeardown)
        function teardownTestClass(testCase)
            testCase.TeardownOnceFcn(testCase);
        end
    end
    
    methods(Hidden, TestMethodSetup)
        function setupTestMethod(testCase)
            testCase.SetupFcn(testCase);
        end
    end
    
    methods(Hidden, TestMethodTeardown)
        function teardownTestMethod(testCase)
            testCase.TeardownFcn(testCase);
        end
    end
    
    methods(Hidden, Test)
        function test(testCase)
            testCase.TestFcn(testCase);
        end
    end
    
    
    methods(Access=private)
        function testCase = FunctionTestCase
            % Constructor is private. Not in model to create explicitly.
        end
    end
    
end

function p = createFromFunctionParser

p = inputParser;
p.addRequired('TestFcn', @validateFcn);
p.addParamValue('SetupFcn', @defaultFixtureFcn, @validateFcn);
p.addParamValue('TeardownFcn', @defaultFixtureFcn, @validateFcn);
p.addParamValue('SetupOnceFcn', @defaultFixtureFcn, @validateFcn);
p.addParamValue('TeardownOnceFcn', @defaultFixtureFcn, @validateFcn);

end

function validateFcn(fcn)
validateattributes(fcn, {'function_handle'}, {}, '', 'fcn');

% Test/Fixture functions must accept exactly one input argument
if nargin(fcn) ~= 1
    throw(MException(message('MATLAB:unittest:functiontests:MustAcceptExactlyOneInputArgument', func2str(fcn))));
end

end

function defaultFixtureFcn(~)
% A do nothing function to be used as fixture setup and teardown when no
% functions have been provided.
end
