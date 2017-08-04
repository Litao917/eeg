classdef IsSameHandleAs < matlab.unittest.constraints.BooleanConstraint
    % IsSameHandleAs - Constraint specifying the same handle instance(s) to another
    %
    %   The IsSameHandleAs constraint produces a qualification failure for any
    %   actual value that is not the same size or does not contain the same
    %   instances as a specified handle array.
    %
    %   IsSameHandleAs methods:
    %       IsSameHandleAs - Class constructor
    %
    %   Examples:
    %
    %       % Define a handle class for use in examples
    %       classdef ExampleHandle < handle
    %       end
    %
    %
    %       import matlab.unittest.constraints.IsSameHandleAs;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       h1 = ExampleHandle;
    %       h2 = ExampleHandle;
    %       testCase.fatalAssertThat(h1, IsSameHandleAs(h1));
    %       testCase.assertThat([h1 h1], IsSameHandleAs([h1 h1]));
    %       testCase.verifyThat([h1 h2 h1], IsSameHandleAs([h1 h2 h1]));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(h1, IsSameHandleAs(h2));
    %       testCase.verifyThat([h1 h1], IsSameHandleAs(h1));
    %       testCase.assertThat(h2, IsSameHandleAs([h2 h2]));
    %       testCase.assumeThat([h1 h2], IsSameHandleAs([h2 h1]));
    %
    %   See also
    %       handle/eq
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % ExpectedHandle -  the expected handle array
        ExpectedHandle
    end
    
    methods
        function constraint = IsSameHandleAs(expectedValue)
            % IsSameHandleAs - Class constructor
            %
            %   IsSameHandleAs(HANDLE) creates a constraint that is able to determine
            %   whether an actual value is an array which contains the same instances
            %   as HANDLE. The actual value array must be the same size as the HANDLE
            %   array, and each element of the actual value must be the same instance
            %   as each corresponding element of the HANDLE array (element-by-element),
            %   or a qualification failure is produced.
            %
            
            validateattributes(expectedValue, {'handle'}, {'nonempty'}, '', 'expectedValue');
            constraint.ExpectedHandle = expectedValue;
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            % Since the ExpectedHandle was validated as a handle in the
            % constructor, we don't need explicit validation here.
            
            tf = false;
            if isequal(size(actual), size(constraint.ExpectedHandle))
                sameHandleMask = constraint.ExpectedHandle == actual;
                tf = all(sameHandleMask(:));
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
                    DiagnosticSense.Positive, actual, constraint.ExpectedHandle);

                actSize = size(actual);
                expSize = size(constraint.ExpectedHandle);
                if ~isequal(actSize, expSize)
                    diag.addCondition(message('MATLAB:unittest:IsSameHandleAs:MustBeSameSize', ...
                        int2str(actSize), int2str(expSize)));
                end
                if ~all(actual == constraint.ExpectedHandle)
                    if isscalar(actual) && isscalar(constraint.ExpectedHandle)
                        condition = message('MATLAB:unittest:IsSameHandleAs:MustBeSameHandle');
                    else
                        condition = message('MATLAB:unittest:IsSameHandleAs:MustBeSameHandleArray');
                    end
                    diag.addCondition(condition);
                end
                actClass = class(actual);
                expClass = class(constraint.ExpectedHandle);
                if ~isa(actual, 'handle')
                    diag.addCondition(message('MATLAB:unittest:IsSameHandleAs:MustBeHandle', actClass));
                end
                if ~strcmp(actClass, expClass)
                    diag.addCondition(message('MATLAB:unittest:IsSameHandleAs:MustBeSameClass', ...
                        actClass, expClass));
                end

                diag.ExpValHeader = getString(message('MATLAB:unittest:IsSameHandleAs:ExpectedHandle'));
            end
        end
        
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.ExpectedHandle);
                diag.addCondition(message('MATLAB:unittest:IsSameHandleAs:MustNotBeSameHandle'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsSameHandleAs:UnexpectedHandle'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
        
end