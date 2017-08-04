classdef ReturnsTrue < matlab.unittest.constraints.BooleanConstraint
    % ReturnsTrue - Constraint specifying a function handle that returns true
    %
    %   The ReturnsTrue constraint produces a qualification failure for any
    %   value that is not a function handle that returns a scalar logical with
    %   a value of true.
    %
    %   Note: When negated using the ~ operator, this constraint does not only
    %   pass when the function handle returns false. It also passes if the
    %   function handle returns any non-scalar value (such as [true true]) or
    %   any non-logical (such as 1). The constraint validates that a
    %   provided function handle actually returns true, so ~ReturnsTrue will
    %   pass for any value that is not scalar and logical with a value of true.
    %
    %   ReturnsTrue methods:
    %       ReturnsTrue - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.ReturnsTrue;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % Note these are for example only, there exist fully featured
    %       % Constraints to better handle these particular comparisons
    %       testCase.verifyThat(@true, ReturnsTrue);
    %       testCase.assumeThat(@() isequal(1,1), ReturnsTrue);
    %       testCase.verifyThat(@() ~strcmp('a','b'), ReturnsTrue);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(@false, ReturnsTrue);
    %       testCase.verifyThat(@() strcmp('a',{'a','a'}), ReturnsTrue);
    %       testCase.assertThat(@() exist('exist'), ReturnsTrue);
    %
    %   See also
    %       IsTrue
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function constraint = ReturnsTrue
            % ReturnsTrue - Class constructor
            %
            %   ReturnsTrue creates a constraint that is able to determine whether an
            %   actual value is a function handle that returns true, and produce an
            %   appropriate qualification failure if it is any other value.
            %
            
        end
        
        function tf = satisfiedBy(~, actual)
            
            if isa(actual,'function_handle')
                returnValue = actual();
                tf = islogical(returnValue) && isscalar(returnValue) && returnValue;
            else
                tf = false; % is not a function handle
            end
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                if isa(actual, 'function_handle')
                    
                    returnValue = actual();
                    
                    diag.ActValHeader = getString(message('MATLAB:unittest:ReturnsTrue:ActualFunctionHandle'));
                    
                    % Logical
                    if ~islogical(returnValue)
                        diag.addCondition(message('MATLAB:unittest:ReturnsTrue:MustHaveLogicalOutput', class(returnValue)));
                    end                        

                    % Scalar
                    if ~isscalar(returnValue)
                        diag.addCondition(message('MATLAB:unittest:ReturnsTrue:MustHaveScalarOutput', ...
                            int2str(size(returnValue))));
                    end
                    
                    % True
                    if returnValue
                        % Do not use ~returnValue in case returnValue is
                        % empty. Recognize that ~[] returns [] and in the
                        % context of an if-condition, both return false.
                    else
                        diag.addCondition(message('MATLAB:unittest:ReturnsTrue:MustEvaluateToTrue'));
                    end
                    
                    diag.addCondition(message('MATLAB:unittest:ReturnsTrue:ActualReturnValue', ...
                        ConstraintDiagnostic.getDisplayableString(returnValue)));
                else
                    diag.addCondition(message('MATLAB:unittest:ReturnsTrue:MustBeFunctionHandle', class(actual)));
                end
                
            end
        end
        
    end
    
    methods (Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(message('MATLAB:unittest:ReturnsTrue:MustNotBeFunctionHandleThatReturnsTrue'));
                diag.ActValHeader = getString(message('MATLAB:unittest:ReturnsTrue:ActualValue'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    

end