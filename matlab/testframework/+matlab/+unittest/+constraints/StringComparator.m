classdef StringComparator < matlab.unittest.constraints.Comparator & ...
                            matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                            matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % StringComparator - Comparator for comparing two MATLAB strings.
    %
    %    The StringComparator comparator supports MATLAB character arrays. By default,
    %    StringComparator performs a case-sensitive comparison using the MATLAB
    %    built-in strcmp function. A string comparator is satisfied if a
    %    non-zero value is returned by the strcmp function.
    %
    %   StringComparator properties:
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %    See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function comparator = StringComparator(varargin)
            comparator = comparator.parse(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = ischar(value);
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            if ~comparator.supports(expVal)
                error(message('MATLAB:unittest:StringComparator:UnsupportedType'));
            end
            
            if ~comparator.supports(actVal)
                bool = false;
                return;
            end
            
            if comparator.IgnoreWhitespace
                actVal = comparator.removeWhitespaceFrom(actVal);
                expVal = comparator.removeWhitespaceFrom(expVal);
            end
            
            if comparator.IgnoreCase
                bool = strcmpi(actVal, expVal);
            else
                bool = strcmp(actVal, expVal);
            end
        end
        
        function diag = getDiagnosticFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if comparator.satisfiedBy(actVal, expVal)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(comparator, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
                
                if comparator.IgnoreWhitespace && comparator.IgnoreCase
                    diag.addCondition(message('MATLAB:unittest:StringComparator:NotEqualIgnoringCaseAndWhitespace'));
                elseif comparator.IgnoreWhitespace
                    diag.addCondition(message('MATLAB:unittest:StringComparator:NotEqualIgnoringWhitespace'));
                elseif comparator.IgnoreCase
                    diag.addCondition(message('MATLAB:unittest:StringComparator:NotEqualIgnoringCase'));
                else
                    diag.addCondition(message('MATLAB:unittest:StringComparator:NotEqual'));
                end
                
                diag.ActValHeader = getString(message('MATLAB:unittest:StringComparator:ActualString'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:StringComparator:ExpectedString'));
            end
        end
    end
end