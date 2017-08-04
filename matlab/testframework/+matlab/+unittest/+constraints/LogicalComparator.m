classdef LogicalComparator < matlab.unittest.constraints.Comparator
    % LogicalComparator - Comparator for comparing two MATLAB logical values.
    %
    %   The LogicalComparator comparator supports MATLAB logicals and
    %   performs a comparison using the isequal method. A logical
    %   comparator is satisfied if the actual and expected values have the
    %   same sparsity and the isequal method returns true.
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function bool = supports(~, value)
            bool = islogical(value);
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            if ~comparator.supports(expVal)
                error(message('MATLAB:unittest:LogicalComparator:UnsupportedType'));
            end
            
            bool = comparator.supports(actVal) && ...
                issparse(actVal) == issparse(expVal) && ...
                isequal(actVal, expVal);
        end
        
        function diag = getDiagnosticFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if comparator.satisfiedBy(actVal, expVal)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(comparator, ...
                    DiagnosticSense.Positive);
            elseif issparse(actVal) ~= issparse(expVal)
                diag = ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:LogicalComparator:NotEqual'));
                diag.ActValHeader = getString(message('MATLAB:unittest:LogicalComparator:ActualLogical'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:LogicalComparator:ExpectedLogical'));
            end
        end
    end
end