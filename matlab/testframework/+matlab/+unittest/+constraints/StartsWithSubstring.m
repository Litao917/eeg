classdef StartsWithSubstring < matlab.unittest.constraints.BooleanConstraint & ...
                               matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                               matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % StartsWithSubstring -  Constraint specifying a string starting with a substring
    %
    %   The StartsWithSubstring constraint produces a qualification failure for
    %   any actual value that is not a string or does not start with an
    %   expected string.
    %
    %   Note: Strings must be in the form of row vectors of type char, but can
    %   include newline characters.
    %
    %   StartsWithSubstring properties:
    %      IgnoreCase       - Boolean that specifies whether to ignore case differences.
    %      IgnoreWhitespace - Boolean that specifies whether to ignore whitespace differences.
    %
    %   StartsWithSubstring methods:
    %       StartsWithSubstring - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.StartsWithSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongString', StartsWithSubstring('Some'));
    %
    %       testCase.fatalAssertThat('SomeLongString', ...
    %           StartsWithSubstring('sOME', 'IgnoringCase', true));
    %
    %       testCase.assertThat('Some Long String', ...
    %           StartsWithSubstring('SomeLong', 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat('SomeLongString', StartsWithSubstring('sOME'));
    %
    %       testCase.verifyThat('SomeLongString', StartsWithSubstring('OtherString'));
    %
    %       testCase.fatalAssert.That('SomeLongString', StartsWithSubstring('Long'));
    %
    %
    %   See also
    %       EndsWithSubstring
    %       ContainsSubstring
    %       IsSubstringOf
    %       Matches
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Prefix - string the value must start with to satisfy the constraint
        Prefix
    end
    
    methods
        function constraint = StartsWithSubstring(prefix, varargin)
            % StartsWithSubstring - Class constructor
            %
            %   StartsWithSubstring(PREFIX) creates a constraint that is able to
            %   determine whether an actual value starts with the PREFIX provided.
            %
            %   StartsWithSubstring(PREFIX, 'IgnoringCase', true) creates a
            %   constraint that is able to determine whether an actual value starts with
            %   the PREFIX provided, while ignoring any differences in case between
            %   the PREFIX and the actual value.
            
            constraint.Prefix = prefix;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ischar(actual) && constraint.hasPrefix(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Prefix);
                diag.ExpValHeader = getString(message('MATLAB:unittest:StartsWithSubstring:ExpectedPrefix'));
                if ischar(actual)
                    if constraint.IgnoreWhitespace && constraint.IgnoreCase
                        condition = message('MATLAB:unittest:StartsWithSubstring:MustStartWithExpectedPrefixIgnoringCaseAndWhitespace');
                    elseif constraint.IgnoreWhitespace
                        condition = message('MATLAB:unittest:StartsWithSubstring:MustStartWithExpectedPrefixIgnoringWhitespace');
                    elseif constraint.IgnoreCase
                        condition = message('MATLAB:unittest:StartsWithSubstring:MustStartWithExpectedPrefixIgnoringCase');
                    else
                        condition = message('MATLAB:unittest:StartsWithSubstring:MustStartWithExpectedPrefix');
                    end
                    
                    diag.addCondition(condition);
                    diag.ActValHeader = getString(message('MATLAB:unittest:StartsWithSubstring:ActualString'));
                else
                    diag.addCondition(message('MATLAB:unittest:StartsWithSubstring:MustBeCharArray', class(actual)));
                end
            end
        end
        
        function constraint = set.Prefix(constraint, prefix)
            validateattributes(prefix, {'char'}, {'row'}, '', 'prefix');
            constraint.Prefix = prefix;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                if constraint.IgnoreWhitespace && constraint.IgnoreCase
                    condition = message('MATLAB:unittest:StartsWithSubstring:MustNotStartWithExpectedPrefixIgnoringCaseAndWhitespace');
                elseif constraint.IgnoreWhitespace
                    condition = message('MATLAB:unittest:StartsWithSubstring:MustNotStartWithExpectedPrefixIgnoringWhitespace');
                elseif constraint.IgnoreCase
                    condition = message('MATLAB:unittest:StartsWithSubstring:MustNotStartWithExpectedPrefixIgnoringCase');
                else
                    condition = message('MATLAB:unittest:StartsWithSubstring:MustNotStartWithExpectedPrefix');
                end
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Prefix);
                diag.addCondition(condition);
                diag.ActValHeader = getString(message('MATLAB:unittest:StartsWithSubstring:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:StartsWithSubstring:UnexpectedPrefix'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end            
    end
    
    methods (Access = private)
        function tf = hasPrefix(constraint, actual)
            % hasPrefix - helper to determine whether a value starts with a
            % string
            
            prefix = constraint.Prefix;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                prefix = constraint.removeWhitespaceFrom(prefix);
            end
            
            if constraint.IgnoreCase
                tf = strncmpi(actual, prefix, length(prefix));
            else
                tf = strncmp(actual, prefix, length(prefix));
            end
        end
    end
end
% LocalWords:  OME
