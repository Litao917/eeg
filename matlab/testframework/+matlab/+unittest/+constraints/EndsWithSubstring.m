classdef EndsWithSubstring < matlab.unittest.constraints.BooleanConstraint & ...
                             matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                             matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % EndsWithSubstring - Constraint specifying a string ending with a substring
    %
    %   The EndsWithSubstring constraint produces a qualification failure for
    %   any actual value that is not a string or does not end with an expected
    %   string.
    %
    %   Note: Strings must be in the form of row vectors of type char, but can
    %   include newline characters.
    %
    %   EndsWithSubstring properties:
    %      IgnoreCase       - Boolean that specifies whether to ignore case differences.
    %      IgnoreWhitespace - Boolean that specifies whether to ignore whitespace differences.
    %
    %   EndsWithSubstring methods:
    %       EndsWithSubstring - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.EndsWithSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongString', EndsWithSubstring('String'));
    %
    %       testCase.verifyThat('SomeLongString', EndsWithSubstring('STRINg', 'IgnoringCase', true));
    %
    %       testCase.assertThat('Some Long String', EndsWithSubstring('LongString', 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongString', EndsWithSubstring('STRINg'));
    %
    %       testCase.verifyThat('SomeLongString', EndsWithSubstring('OtherString'));
    %
    %       testCase.verifyThat('SomeLongString', EndsWithSubstring('Long'));
    %
    %
    %   See also
    %       StartsWithSubstring
    %       ContainsSubstring
    %       IsSubstringOf
    %       Matches
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Suffix - string the value must end with to satisfy the constraint
        Suffix
    end
    
    methods
        function constraint = EndsWithSubstring(suffix, varargin)
            % EndsWithSubstring - Class constructor
            %
            %   EndsWithSubstring(SUFFIX) creates a constraint that is able to
            %   determine whether an actual value ends with the SUFFIX provided.
            %
            %   EndsWithSubstring(SUFFIX, 'IgnoringCase', true) creates a
            %   constraint that is able to determine whether an actual value ends with
            %   the SUFFIX provided, while ignoring any differences in case between
            %   the SUFFIX and the actual value.
            
            constraint.Suffix = suffix;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ischar(actual) && constraint.hasSuffix(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Suffix);
                diag.ExpValHeader = getString(message('MATLAB:unittest:EndsWithSubstring:ExpectedSuffix'));
                if ischar(actual)
                    if constraint.IgnoreWhitespace && constraint.IgnoreCase
                        condition = message('MATLAB:unittest:EndsWithSubstring:MustEndWithExpectedIgnoringCaseAndWhitespace');
                    elseif constraint.IgnoreWhitespace
                        condition = message('MATLAB:unittest:EndsWithSubstring:MustEndWithExpectedIgnoringWhitespace');
                    elseif constraint.IgnoreCase
                        condition = message('MATLAB:unittest:EndsWithSubstring:MustEndWithExpectedIgnoringCase');
                    else
                        condition = message('MATLAB:unittest:EndsWithSubstring:MustEndWithExpected');
                    end
                    
                    diag.addCondition(condition);
                    diag.ActValHeader = getString(message('MATLAB:unittest:EndsWithSubstring:ActualString'));
                else
                    diag.addCondition(message('MATLAB:unittest:EndsWithSubstring:ExpectedCharArray', class(actual)));
                end
            end
        end
        
        function constraint = set.Suffix(constraint, suffix)
            validateattributes(suffix, {'char'}, {'row'}, '', 'suffix');
            constraint.Suffix = suffix;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                if constraint.IgnoreWhitespace && constraint.IgnoreCase
                    condition = message('MATLAB:unittest:EndsWithSubstring:MustNotEndWithUnexpectedIgnoringCaseAndWhitespace');
                elseif constraint.IgnoreWhitespace
                    condition = message('MATLAB:unittest:EndsWithSubstring:MustNotEndWithUnexpectedIgnoringWhitespace');
                elseif constraint.IgnoreCase
                    condition = message('MATLAB:unittest:EndsWithSubstring:MustNotEndWithUnexpectedIgnoringCase');
                else
                    condition = message('MATLAB:unittest:EndsWithSubstring:MustNotEndWithUnexpected');
                end
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Suffix);
                diag.addCondition(condition);
                diag.ActValHeader = getString(message('MATLAB:unittest:EndsWithSubstring:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:EndsWithSubstring:UnexpectedSuffix'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    methods (Access = private)
        function tf = hasSuffix(constraint, actual)
            % hasSuffix - helper to determine whether a value ends with a
            % string
            
            suffix = constraint.Suffix;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                suffix = constraint.removeWhitespaceFrom(suffix);
            end
            
            if constraint.IgnoreCase
                tf = strncmpi(fliplr(actual), fliplr(suffix), length(suffix));
            else
                tf = strncmp(fliplr(actual), fliplr(suffix), length(suffix));
            end
        end
    end
end
% LocalWords:  STRI Ng
