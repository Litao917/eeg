classdef IsAnything < matlab.unittest.constraints.Constraint
    % IsAnything - Constraint specifying anything.
    %
    %   The IsAnything constraint is satisfied by any value.
    %
    %   IsAnything methods:
    %       IsAnything - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsAnything;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       testCase.verifyThat(NaN, IsAnything);
    %       testCase.verifyThat(inputParser, IsAnything);
    %       testCase.verifyThat(1:10, IsAnything);
    %       testCase.verifyThat(-Inf+5j, IsAnything);
    
    %  Copyright 2013 The MathWorks, Inc.
    
    methods
        function constraint = IsAnything
            % IsAnything - Class constructor
            %
            %   IsAnything creates a constraint that is satisfied by any value.
        end
        
        function bool = satisfiedBy(~,~)
            bool = true;
        end
        
        function diag = getDiagnosticFor(constraint,~)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                DiagnosticSense.Positive);
        end
    end
end