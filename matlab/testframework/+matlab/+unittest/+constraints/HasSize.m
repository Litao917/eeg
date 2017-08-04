classdef HasSize < matlab.unittest.constraints.BooleanConstraint
    % HasSize - Constraint specifying an expected size of an array
    %
    %   The HasSize constraint produces a qualification failure for
    %   any actual value array that does not have a specified array size.
    %
    %   HasSize methods:
    %       HasSize - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.HasSize;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(ones(2, 5, 3), HasSize([2 5 3]));
    %       testCase.assumeThat({'SomeString', 'SomeOtherString'}, HasSize([1 2]));
    %       testCase.fatalAssertThat([1 2 3; 4 5 6], HasSize([2 3]));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat([2 3], HasSize([3 2]));
    %       testCase.verifyThat([1 2 3; 4 5 6], HasSize(6));
    %       testCase.assertThat(eye(2), HasSize([4 1]));
    %
    %   See also
    %       HasElementCount
    %       HasLength
    %       IsEmpty
    %       size
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    
    properties (SetAccess=private)
        % Size - size a value must have to satisfy the constraint
        Size
    end
    
    
    methods
        function constraint = HasSize(size)
            % HasSize - Class constructor
            %
            %   HasSize(SIZE) creates a constraint that is able to determine
            %   whether an actual value is an array whose size is equal to SIZE.
            %
                        
            constraint.Size = size;
            
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = isequal(size(actual), constraint.Size);
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
                
                % Use a sub-diagnostic to report the value's wrong size
                sizeDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, size(actual), constraint.Size);
                sizeDiag.Description = getString(message('MATLAB:unittest:HasSize:MustHaveExpectedSize'));
                sizeDiag.ActValHeader = getString(message('MATLAB:unittest:HasSize:ActualSize'));
                sizeDiag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:ExpectedSize'));
                diag.addCondition(sizeDiag);
            end
        end
        
        function constraint = set.Size(constraint, size)
            validateattributes(                             ...
                size,                                       ...
                {'numeric'},                                ...
                {'row','nonnegative','finite','integer'},   ...
                '', 'size');
            
            if numel(size) < 2
                error(message('MATLAB:unittest:HasSize:ExpectedNonScalar'));
            end
            constraint.Size = size;
        end
    end
    
    methods (Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Size);
                diag.addCondition(message('MATLAB:unittest:HasSize:MustNotHaveUnexpectedSize'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:UnexpectedSize'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    
end