classdef Matches < matlab.unittest.constraints.BooleanConstraint & ...
                   matlab.unittest.internal.constraints.IgnoringCaseMixin
    % Matches - Ensure that a string matches a given regular expression
    %
    %   The Matches constraint produces a qualification failure for any actual
    %   value that does not match a given regular expression string.
    %
    %   Note: Strings must be in the form of row vectors of type char, but can
    %   include newline characters.
    %
    %   Matches properties:
    %      IgnoreCase       - Boolean that specifies whether to ignore case differences.
    %
    %   Matches methods:
    %       Matches - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.Matches;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeString', Matches('Some[Ss]?tring'));
    %       testCase.assertThat('Somestring', Matches('Some[Ss]?tring'));
    %       testCase.fatalAssertThat('Sometring', Matches('Some[Ss]?tring'));
    %       testCase.verifyThat('SomeString', Matches('some*', 'IgnoringCase', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assumeThat('SomeSstring', Matches('Some[Ss]?tring'));
    %
    %   See also
    %       regexp
    %       ContainsSubstring
    %       IsSubstringOf
    %       StartsWithSubstring
    %       EndsWithSubstring
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Expression - regular expression the value must match to satisfy the constraint
        Expression
    end
    
    methods
        function constraint = Matches(expression, varargin)
            % Matches - Class constructor
            %
            %   Matches(EXPRESSION) creates a constraint that is able to
            %   determine whether an actual value contains the EXPRESSION provided.
            
            constraint.Expression = expression;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ischar(actual) && constraint.matches(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Expression);
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:ExpectedRegularExpression'));
                if ischar(actual)
                    if constraint.IgnoreCase
                        diag.addCondition(message('MATLAB:unittest:Matches:MustMatchRegularExpressionIgnoringCase'));
                    else
                        diag.addCondition(message('MATLAB:unittest:Matches:MustMatchRegularExpression'));
                    end
                    diag.ActValHeader = getString(message('MATLAB:unittest:Matches:ActualString'));
                else
                    diag.addCondition(message('MATLAB:unittest:Matches:MustBeCharArray', class(actual)));
                end
            end
        end
        
        function constraint = set.Expression(constraint, expression)
            validateattributes(expression, {'char'}, {'row'}, '', 'expression');
            constraint.Expression = expression;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Expression);
                if constraint.IgnoreCase
                    diag.addCondition(message('MATLAB:unittest:Matches:MustNotMatchRegularExpressionIgnoringCase'));
                else
                    diag.addCondition(message('MATLAB:unittest:Matches:MustNotMatchRegularExpression'));
                end
                diag.ActValHeader = getString(message('MATLAB:unittest:Matches:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:UnexpectedRegularExpression'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    methods (Access = private)
        function tf = matches(constraint, actual)
            % matches - helper to determine whether a value matches the
            % expression
            
            if constraint.IgnoreCase
                caseHandling = 'ignorecase';
            else
                caseHandling = 'matchcase';
            end
            
            tf = ~isempty(regexp(actual, constraint.Expression, 'once', caseHandling));
        end
    end
end
% LocalWords:  tring Somestring Sometring Sstring ignorecase matchcase
