classdef ContainsSubstring < matlab.unittest.constraints.BooleanConstraint & ...
                             matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                             matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % ContainsSubstring - Constraint specifying a string containing a substring
    %
    %   The ContainsSubstring constraint produces a qualification failure for
    %   any actual value that is not a string or does not contain an expected
    %   string.
    %
    %   Note: Strings must be in the form of row vectors of type char, but can
    %   include newline characters.
    %
    %   ContainsSubstring methods:
    %       ContainsSubstring - Class constructor
    %
    %   ContainsSubstring properties:
    %      IgnoreCase       - Boolean that specifies whether to ignore case differences.
    %      IgnoreWhitespace - Boolean that specifies whether to ignore whitespace differences.
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.ContainsSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('Long'));
    %
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('lonG','IgnoringCase', true));
    %
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('Some Long String','IgnoringWhitespace', true));
    %
    %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('lonG'));
    %
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('OtherString'));
    %
    %       testCase.verifyThat('SomeLongString', ContainsSubstring('SomeLongStringThatIsLonger'));
    %
    %   See also
    %       IsSubstringOf
    %       StartsWithSubstring
    %       EndsWithSubstring
    %       Matches
    
    %  Copyright 2010-2012 The MathWorks, Inc.
   
    properties (SetAccess = private)
         % Substring - string a value must contain to satisfy the constraint
        Substring
    end
    
    methods
        function constraint = ContainsSubstring(substring, varargin)
            % ContainsSubstring - Class constructor
            %
            %   ContainsSubstring(SUBSTRING) creates a constraint that is able to
            %   determine whether an actual value contains the SUBSTRING provided.
            %
            %   ContainsSubstring(SUBSTRING, 'IgnoringCase', true) creates a
            %   constraint that is able to determine whether an actual value contains
            %   the SUBSTRING provided, while ignoring any differences in case between
            %   the SUBSTRING and the actual value.
            %
            
            constraint.Substring = substring;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ischar(actual) && constraint.containsSubstring(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Substring);
                diag.ExpValHeader = getString(message('MATLAB:unittest:ContainsSubstring:ExpectedSubstring'));
                if ischar(actual)
                    if constraint.IgnoreWhitespace && constraint.IgnoreCase
                        condition = message('MATLAB:unittest:ContainsSubstring:MustContainExpectedIgnoringCaseAndWhitespace');
                    elseif constraint.IgnoreWhitespace
                        condition = message('MATLAB:unittest:ContainsSubstring:MustContainExpectedIgnoringWhitespace');
                    elseif constraint.IgnoreCase
                        condition = message('MATLAB:unittest:ContainsSubstring:MustContainExpectedIgnoringCase');
                    else
                        condition = message('MATLAB:unittest:ContainsSubstring:MustContainExpected');
                    end
                    
                    diag.addCondition(condition);
                    diag.ActValHeader = getString(message('MATLAB:unittest:ContainsSubstring:ActualString'));
                else
                    diag.addCondition(message('MATLAB:unittest:ContainsSubstring:ExpectedCharArray', class(actual)));
                end
            end
        end
        
        function constraint = set.Substring(constraint, substring)
            validateattributes( substring, {'char'}, {'row'}, '', 'substring');
            constraint.Substring = substring;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                if constraint.IgnoreWhitespace && constraint.IgnoreCase
                    condition = message('MATLAB:unittest:ContainsSubstring:MustNotContainUnexpectedIgnoringCaseAndWhitespace');
                elseif constraint.IgnoreWhitespace
                    condition = message('MATLAB:unittest:ContainsSubstring:MustNotContainUnexpectedIgnoringWhitespace');
                elseif constraint.IgnoreCase
                    condition = message('MATLAB:unittest:ContainsSubstring:MustNotContainUnexpectedIgnoringCase');
                else
                    condition = message('MATLAB:unittest:ContainsSubstring:MustNotContainUnexpected');
                end
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Substring);
                diag.addCondition(condition);
                diag.ActValHeader = getString(message('MATLAB:unittest:ContainsSubstring:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:ContainsSubstring:UnexpectedSubstring'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    methods (Access = private)
        function tf = containsSubstring(constraint, actual)
            % helper to determine whether the value contains the substring.
            
            substring = constraint.Substring;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                substring = constraint.removeWhitespaceFrom(substring);
            end
            
            if constraint.IgnoreCase
                actual = lower(actual);
                substring = lower(substring);
            end
            
            tf = ~isempty(strfind(actual, substring));
        end
    end
end

% LocalWords:  lon
