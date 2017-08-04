classdef(Hidden) ScriptTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    % ScriptTestCaseProvider is a TestCaseProvider that turns a script into
    % a test suite, with each cell in the script its own independent test.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    
    
    
    properties(Dependent, SetAccess=immutable)
        TestCase
        TestClass
        TestMethod
    end
    
    properties(SetAccess=immutable)
        
        TestName
        TestParentName
    end
    
    properties(GetAccess=private, SetAccess=immutable)
        TestCode
    end
    
    
    methods
        function provider = ScriptTestCaseProvider(scriptFileModel)

            if ~nargin
                % Allow preallocation
                return
            end
            
            % Preallocate
            numTests = numel(scriptFileModel.TestCellNames);
            provider(numTests) = matlab.unittest.internal.ScriptTestCaseProvider;
            
            % Assign properties
            [provider.TestParentName] = deal(scriptFileModel.ScriptName);
            [provider.TestName] = scriptFileModel.TestCellNames{:};
            [provider.TestCode] = scriptFileModel.TestCellContent{:};
            
        end
        
        function class = get.TestClass(~)
            class = ?matlab.unittest.FunctionTestCase;
        end
        
        function method = get.TestMethod(provider)
            method = provider.TestClass.findobj('Test',true);
        end
        
        function testCase = createTestCaseFromClassPrototype(provider, ~)
            testCase = copy(provider.TestCase);
        end
        
        function testCase = get.TestCase(provider)
            import matlab.unittest.FunctionTestCase;
            
            testCase = FunctionTestCase.fromFunction(@(testCase) evaluateCodeSection(testCase, provider.TestCode));
        end
    end
end


function evaluateCodeSection(testCase, codeSection)
import matlab.unittest.Verbosity;
import matlab.unittest.internal.diagnostics.ScriptContentsDiagnostic;

testCase.log(Verbosity.Verbose, ScriptContentsDiagnostic(codeSection));

% Evaluate the code in a try catch and rethrow the error in order to
% prevent the eval from showing in the error report.
try
    eval(codeSection);
catch e
    throw(e);
end

end

