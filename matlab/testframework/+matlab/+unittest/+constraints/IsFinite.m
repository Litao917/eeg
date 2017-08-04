classdef IsFinite < matlab.unittest.constraints.BooleanConstraint
    % IsFinite - Constraint specifying a finite value
    %
    %   The IsFinite constraint produces a qualification failure for
    %   any value that does not contain all finite values.
    %
    %   IsFinite methods:
    %       IsFinite - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsFinite;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsFinite);
    %       testCase.assumeThat([0 5 1], IsFinite);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(NaN, IsFinite);
    %       testCase.verifyThat(Inf, IsFinite);
    %       testCase.assertThat(-Inf, IsFinite);
    %       testCase.verifyThat([5 6 NaN 8], IsFinite);
    %       testCase.fatalAssertThat([5 6 7 Inf], IsFinite);
    %       testCase.verifyThat(5+NaN*i, IsFinite);
    %
    %   See also
    %       HasInf
    %       HasNaN
    %       isfinite
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function constraint = IsFinite
            % IsFinite - Class constructor
            %
            %   IsFinite creates a constraint that is able to determine whether all
            %   values of an actual value array are finite, and produce an appropriate
            %   qualification failure if the array contains any non-finite value.
            %
            
        end
        
        function tf = satisfiedBy(~, actual)
            tf = false;
            % Check isnumeric to avoid an error if "actual" is an object
            % that doesn't support isfinite().
            if isnumeric(actual)
                mask = isfinite(actual);
                tf = all(mask(:));
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
                
                if isnumeric(actual)
                    if isscalar(actual)
                        diag.addCondition(message('MATLAB:unittest:IsFinite:MustBeFinite'));
                    else
                        indices = find(~isfinite(actual));
                        diag.addCondition(message('MATLAB:unittest:IsFinite:AllMustBeFinite', ...
                            ConstraintDiagnostic.getDisplayableString(indices))); %#ok<FNDSB>
                    end
                else
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustBeNumeric'));
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
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustNotBeFinite'));
                else
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustHaveOneNonFiniteElement'));
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    
end