classdef CellComparator < matlab.unittest.internal.constraints.ContainerComparator
    % CellComparator - Comparator for comparing MATLAB cell arrays.
    %
    %   The CellComparator natively supports cell arrays and performs a
    %   comparison by iterating over each element of the cell array and
    %   recursing if necessary. By default, a cell comparator only supports
    %   empty cell arrays. However, it can support other data types during
    %   recursion by passing a comparator to the constructor. Also, by
    %   setting the Recursive property true and including the
    %   CellComparator in a ComparatorList, the CellComparator can support
    %   arbitrary collections of cell arrays and other data types.
    %
    %   CellComparator properties:
    %      Recursive        - Optional boolean to compare data structures recursively
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    
    % Copyright 2010-2012 The MathWorks, Inc.
    
    methods
        function comparator = CellComparator(varargin)
            comparator = comparator@matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = iscell(value);
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            comparator.validateExpVal(expVal);
            
            bool = iscell(actVal) && isequal(size(expVal), size(actVal)) && ...
                comparator.cellsHaveSameContents(actVal, expVal);
        end
        
        function diag = getDiagnosticFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comparator.validateExpVal(expVal);
            
            if ~iscell(actVal)
                diag = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
            elseif ~isequal(size(expVal), size(actVal))
                diag = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
            else
                [bool, subsrefPath, cell1, cell2, comp] = comparator.findFirstDifferingCell(actVal, expVal);
                
                if bool
                    diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(comparator, ...
                        DiagnosticSense.Positive);
                else
                    diag = comp.getDiagnosticFor(cell1, cell2);
                    diag.pushOnRecursivePath(subsrefPath);
                end
            end
        end
    end
    
    methods (Access = private)
        function validateExpVal(comparator, expVal)
            if ~comparator.supports(expVal)
                error(message('MATLAB:unittest:CellComparator:UnsupportedType'));
            end
        end
        
        function bool = cellsHaveSameContents(comparator, actVal, expVal)
            bool = comparator.findFirstDifferingCell(actVal, expVal);
        end
        
        function [bool, subsrefPath, actCell, expCell, comp] = findFirstDifferingCell(comparator, actVal, expVal)
            % Finds the first pair of mismatching cells, the subsref path
            % to get there, and the comparator to use on the dereferenced
            % cells. If all cells match, return all empty matrices.
            
            bool = true;
            
            subsrefPath = '';
            actCell = [];
            expCell = [];
            comp = [];
            
            for n = 1:numel(expVal)
                actCell = actVal{n};
                expCell = expVal{n};
                comp = comparator.getComparatorFor(expCell);
                bool = comp.satisfiedBy(actCell, expCell);
                if ~bool
                    subsrefPath = sprintf('{%d}', n);
                    return;
                end
            end
        end
    end
end