% This class is undocumented, see the help for ElementwiseTolerance.
%
%   See also ElementwiseTolerance/and ElementwiseTolerance/or

%  Copyright 2012-2013 The MathWorks, Inc.

classdef (Hidden) CompositeTolerance < matlab.unittest.internal.constraints.ElementwiseTolerance
    properties (SetAccess=private, GetAccess=protected)
        % Left tolerance that is being AND'ed or OR'ed -- must be an ElementwiseTolerance
        FirstTolerance
        
        % Right tolerance that is being AND'ed or OR'ed -- must be an ElementwiseTolerance
        SecondTolerance
    end
    
    properties (Hidden, Constant, GetAccess=protected)
        FirstConditionHeader = getString(message('MATLAB:unittest:Tolerance:FirstToleranceHeader'));
        SecondConditionHeader = getString(message('MATLAB:unittest:Tolerance:SecondToleranceHeader'));
        ConditionFooter = getString(message('MATLAB:unittest:Tolerance:ToleranceFooter'));
    end
    
    properties (Abstract, Hidden, Constant, GetAccess=protected)
        % BooleanOperation - A string specifying the boolean operation (AND or OR).
        BooleanOperation
    end
    
    methods
        function tolerance = CompositeTolerance(firstTolerance,secondTolerance)
            % CompositeTolerance - Construct a CompositeTolerance from two
            %   ElementwiseTolerances.
            
            validateattributes(firstTolerance, {'matlab.unittest.internal.constraints.ElementwiseTolerance'}, ....
                {'scalar'}, '', 'firstTolerance');
            validateattributes(secondTolerance, {'matlab.unittest.internal.constraints.ElementwiseTolerance'}, ...
                {'scalar'}, '', 'secondTolerance');
            
            [tolerance.Types, tolerance.Sizes] = combineTypesAndSizes(firstTolerance, secondTolerance);
            tolerance.FirstTolerance = firstTolerance;
            tolerance.SecondTolerance = secondTolerance;
        end
    end
    
    methods
        function diag = getDiagnosticFor(tolerance, actVal, expVal)
            % getDiagnosticFor - Returns a diagnostic object containing
            %   information about the result of a comparison.
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % Early return if there is a discrepancy (size, type, sparsity, etc.)
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            failedIndices = ~tolerance.compareValues(actVal, expVal);
            
            if any(failedIndices(:))
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                
                if ~isscalar(actVal)
                    diag.Description = sprintf('%s\n\n%s\n%s', ...
                        diag.Description, ...
                        getString(message('MATLAB:unittest:Tolerance:OverallFailingIndices')), ...
                        ConstraintDiagnostic.getDisplayableString(find(failedIndices(:)'))); %#ok<FNDSB>
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive);
            end
            diag.DisplayConditions = true;
            
            % Diagnostic from first tolerance
            diag1 = tolerance.FirstTolerance.getDiagnosticFor(actVal, expVal);
            diag1.DisplayActVal = false;
            diag1.DisplayExpVal = false;
            
            % Diagnostic from second tolerance
            diag2 = tolerance.SecondTolerance.getDiagnosticFor(actVal, expVal);
            diag2.DisplayActVal = false;
            diag2.DisplayExpVal = false;
            
            % Add both conditions
            diag.addCondition(diag1);
            diag.addCondition(diag2);
        end
    end
end

% LocalWords:  Elementwise AND'ed OR'ed
