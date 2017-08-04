classdef IsSubstringOf < matlab.unittest.constraints.BooleanConstraint & ...
                         matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                         matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % IsSubstringOf -  Constraint specifying a substring of another string
    %
    %   The IsSubstringOf constraint produces a qualification failure for any
    %   actual value that is not a string or cannot be found within an expected
    %   string.
    %
    %   Note: Strings must be in the form of row vectors of type char, but can
    %   include newline characters.
    %
    %   IsSubstringOf properties:
    %      IgnoreCase       - Boolean that specifies whether to ignore case differences.
    %      IgnoreWhitespace - Boolean that specifies whether to ignore whitespace differences.
    %
    %   IsSubstringOf methods:
    %       IsSubstringOf - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsSubstringOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('Long', IsSubstringOf('SomeLongString'));
    %
    %       testCase.fatalAssertThat('lonG', IsSubstringOf('SomeLongString', 'IgnoringCase', true));
    %
    %       testCase.assertThat('LongString', IsSubstringOf('Some Long String', 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat('lonG', IsSubstringOf('SomeLongString'));
    %
    %       testCase.verifyThat('OtherString', IsSubstringOf('SomeLongString'));
    %
    %       testCase.assumeThat('SomeLongStringThatIsLonger', IsSubstringOf('SomeLongString'));
    %
    %
    %   See also
    %       ContainsSubstring
    %       StartsWithSubstring
    %       EndsWithSubstring
    %       Matches
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Superstring - string a value must be found inside to satisfy the constraint
        Superstring
    end
    
    methods
        function constraint = IsSubstringOf(superstring, varargin)
            % IsSubstringOf - Class constructor
            %
            %   IsSubstringOf(SUPERSTRING) creates a constraint that is able to
            %   determine whether an actual value is a substring of the SUPERSTRING
            %   provided.
            %
            %   IsSubstringOf(SUPERSTRING, 'IgnoringCase', true) creates a constraint
            %   that is able to determine whether an actual value is a substring of the
            %   SUPERSTRING provided, while ignoring any differences in case between
            %   the SUPERSTRING and the actual value.
            
            constraint.Superstring = superstring;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ischar(actual) && constraint.isSubstringOf(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Superstring);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsSubstringOf:ExpectedSuperstring'));
                if ischar(actual)
                    if constraint.IgnoreWhitespace && constraint.IgnoreCase
                        condition = message('MATLAB:unittest:IsSubstringOf:MustBeSubstringIgnoringCaseAndWhitespace');
                    elseif constraint.IgnoreWhitespace
                        condition = message('MATLAB:unittest:IsSubstringOf:MustBeSubstringIgnoringWhitespace');
                    elseif constraint.IgnoreCase
                        condition = message('MATLAB:unittest:IsSubstringOf:MustBeSubstringIgnoringCase');
                    else
                        condition = message('MATLAB:unittest:IsSubstringOf:MustBeSubstring');
                    end
                    
                    diag.addCondition(condition);
                    diag.ActValHeader = getString(message('MATLAB:unittest:IsSubstringOf:ActualString'));
                else
                    diag.addCondition(message('MATLAB:unittest:IsSubstringOf:MustBeCharArray', class(actual)));
                end
            end
        end
        
        function constraint = set.Superstring(constraint, superstring)
            validateattributes(superstring, {'char'}, {'row'}, '', 'superstring');
            constraint.Superstring = superstring;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                if constraint.IgnoreWhitespace && constraint.IgnoreCase
                    condition = message('MATLAB:unittest:IsSubstringOf:MustNotBeSubstringIgnoringCaseAndWhitespace');
                elseif constraint.IgnoreWhitespace
                    condition = message('MATLAB:unittest:IsSubstringOf:MustNotBeSubstringIgnoringWhitespace');
                elseif constraint.IgnoreCase
                    condition = message('MATLAB:unittest:IsSubstringOf:MustNotBeSubstringIgnoringCase');
                else
                    condition = message('MATLAB:unittest:IsSubstringOf:MustNotBeSubstring');
                end
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Superstring);
                diag.addCondition(condition);
                diag.ActValHeader = getString(message('MATLAB:unittest:IsSubstringOf:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsSubstringOf:UnexpectedSuperstring'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    methods (Access = private)
        function tf = isSubstringOf(constraint, actual)
            % helper to determine whether the value is a substring of the
            % expected.
            
            super = constraint.Superstring;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                super = constraint.removeWhitespaceFrom(super);
            end
            
            if constraint.IgnoreCase
                actual = lower(actual);
                super = lower(super);
            end
            
            tf = ~isempty(strfind(super, actual));
        end
    end
end
% LocalWords:  lon Superstring SUPERSTRING superstring
