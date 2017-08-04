classdef IsEmpty < matlab.unittest.constraints.BooleanConstraint
    % IsEmpty - Constraint specifying an empty value
    %
    %   The IsEmpty constraint produces a qualification failure for
    %   any non-empty actual value array.
    %
    %   IsEmpty methods:
    %       IsEmpty - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsEmpty;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(ones(2, 5, 0, 3), IsEmpty);
    %       testCase.assertThat('', IsEmpty);
    %       testCase.assumeThat(MException.empty, IsEmpty);
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat([2 3], IsEmpty);
    %       testCase.verifyThat({[], [], []}, IsEmpty);
    %
    %   See also
    %       HasElementCount
    %       HasLength
    %       HasSize
    %       isempty
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    methods
        function constraint = IsEmpty % Only needed for documentation text
            % IsEmpty - Class constructor
            %
            %   IsEmpty creates a constraint that is able to determine
            %   whether an actual value is empty.
            %
            
        end
            
        function tf = satisfiedBy(~, actual)
            tf = isempty(actual); 
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
                diag.addCondition(message('MATLAB:unittest:IsEmpty:MustBeEmpty'));
                diag.addCondition(message('MATLAB:unittest:IsEmpty:ActualSize', int2str(size(actual))));
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
                diag.addCondition(message('MATLAB:unittest:IsEmpty:MustNotBeEmpty'));
                % Even though we know the actual size is empty, show it
                % anyway since "empty" sizes vary (prod(size)==0).
                diag.addCondition(message('MATLAB:unittest:IsEmpty:ActualSize', int2str(size(actual))));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
end

