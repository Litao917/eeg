classdef HasNaN < matlab.unittest.constraints.BooleanConstraint
    % HasNaN - Constraint specifying an array containing a NaN value
    %
    %   The HasNaN constraint produces a qualification failure for a value that
    %   does not contain any NaN values.
    %
    %   HasNaN methods:
    %       HasNaN - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.HasNaN;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(NaN, HasNaN);
    %       testCase.verifyThat([NaN Inf], HasNaN);
    %       testCase.verifyThat([4 NaN], HasNaN);
    %       testCase.verifyThat([-Inf 5 NaN], HasNaN);
    %       testCase.verifyThat(NaN+Inf*i, HasNaN);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(Inf, HasNaN);
    %       testCase.verifyThat([5 Inf], HasNaN);
    %       testCase.verifyThat(Inf+6i, HasNaN);
    %       testCase.verifyThat([5 6 Inf 8], HasNaN);
    %       testCase.verifyThat([5 6 7 8], HasNaN);
    %
    %   See also
    %       IsFinite
    %       HasInf
    %       isnan
    %
    
    %  Copyright 2010-2012 The MathWorks, Inc.
      
    methods
        function constraint = HasNaN
            % HasNaN - Class constructor
            %
            %   HasNaN creates a constraint that is able to determine whether any
            %   value of an actual value array is NaN, and produce an appropriate
            %   qualification failure if the array does not contain any NaN values.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = false;
            % Check isfloat to avoid an error if "actual" is an object that
            % doesn't support isnan().
            if isfloat(actual)
                nanMask = isnan(actual);
                tf = any(nanMask(:));
            end
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
                if ~isfloat(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustBeFloatingPoint', class(actual)));
                end
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustBeNaN'));
                else
                    diag.addCondition(message('MATLAB:unittest:HasNaN:AtLeastOneElementMustBeNaN'));
                end
            end
        end
    end
    
    
    methods (Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustNotBeNaN'));
                else
                    truncatedArrayString = ConstraintDiagnostic.getDisplayableString(find(isnan(actual))); %#ok<FNDSB>
                    diag.addCondition(message('MATLAB:unittest:HasNaN:AllElementsMustBeNonNaN', truncatedArrayString));
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
end