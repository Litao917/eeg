classdef IsSparse < matlab.unittest.constraints.BooleanConstraint
    % IsSparse - Constraint specifying a sparse array
    %
    %   The IsSparse constraint produces a qualification failure for
    %   any value that is not sparse.
    %
    %   IsSparse methods:
    %       IsSparse - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsSparse;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(sparse(5), IsSparse);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat(5, IsSparse);
    %
    %   See also
    %       issparse
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function constraint = IsSparse
            % IsSparse - Class constructor
            %
            %   IsSparse creates a constraint that is able to determine whether an actual
            %   value array is sparse, and produce an appropriate qualification
            %   failure if the array is not real.
            %
            
        end
        
        function tf = satisfiedBy(~, actual)
            tf = issparse(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                diag.addCondition(message('MATLAB:unittest:IsSparse:MustBeSparse'));
            end
        end
        
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(message('MATLAB:unittest:IsSparse:MustNotBeSparse'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
end