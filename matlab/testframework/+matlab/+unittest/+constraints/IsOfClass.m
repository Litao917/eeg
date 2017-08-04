classdef IsOfClass < matlab.unittest.constraints.BooleanConstraint
    % IsOfClass - Constraint specifying a given exact type
    %
    %   The IsOfClass constraint produces a qualification failure for any
    %   actual value whose class is not the specified MATLAB class. The
    %   expected class can be specified either by its classname as a char or by
    %   the expected meta.class instance.
    %
    %   IsOfClass methods:
    %       IsOfClass - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsOfClass;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsOfClass('double'));
    %       testCase.assertThat(@sin, IsOfClass(?function_handle));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsOfClass('char'));
    %       testCase.assertThat('sin', IsOfClass(?function_handle));
    %
    %       classdef DerivedExample < BaseExample
    %       end
    %       testCase.assertThat(DerivedExample, IsOfClass(?BaseExample));
    %
    %   See also
    %       IsInstanceOf
    %       class
    
    %  Copyright 2010-2012 The MathWorks, Inc.

    properties (SetAccess=private)
        % Class - the class name a value must be to satisfy the constraint
        Class
    end
    
    
    methods
        function constraint = IsOfClass(class)
            % IsOfClass - Class constructor
            %
            %   IsOfClass(CLASS) creates a constraint that is able to determine whether
            %   an actual value's class matches the CLASS provided. This is an exact
            %   class match which does not succeed if CLASS is a superclass if the
            %   actual value instance. CLASS can either be a char whose value is a
            %   fully qualified class name, or CLASS can be an instance of meta.class.
            %
            constraint.Class = class;
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = strcmp(class(actual), constraint.Class);
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
                
                % Use a sub-diagnostic to report the value's wrong class
                classDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive,  class(actual), constraint.Class);
                classDiag.Description = getString(message('MATLAB:unittest:IsOfClass:MustBeClass'));
                classDiag.ActValHeader = getString(message('MATLAB:unittest:IsOfClass:ActualClass'));
                classDiag.ExpValHeader = getString(message('MATLAB:unittest:IsOfClass:ExpectedClass'));
                diag.addCondition(classDiag);
            end
        end
        
        function constraint = set.Class(constraint, class)
            
            validateattributes(class, {'char', 'meta.class'}, {'nonempty'}, '', 'class');                
            
            if ~ischar(class)
                validateattributes(class, {'meta.class'}, {'scalar'}, '', 'class');
                class = class.Name;
            end            
            
            constraint.Class = class;
        end
    end
    
    methods (Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Class);
                diag.addCondition(message('MATLAB:unittest:IsOfClass:MustNotBeClass'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsOfClass:UnexpectedClass'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
        
end