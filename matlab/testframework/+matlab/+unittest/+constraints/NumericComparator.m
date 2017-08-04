classdef NumericComparator < matlab.unittest.constraints.Comparator & ...
                             matlab.unittest.internal.constraints.WithinMixin
    % NumericComparator - Comparator for comparing MATLAB numeric data types.
    %
    %   The NumericComparator comparator supports any MATLAB numeric data type.
    %   A numeric comparator is satisfied if inputs are of the same class with
    %   equivalent size, complexity, and sparsity and the built-in isequaln
    %   returns true.
    %
    %   When a tolerance is supplied, NumericComparator first checks for
    %   equivalent class, size, and sparsity of the actual and expected
    %   values. If these checks fail, the comparator is not satisfied. If
    %   these checks pass and the isequaln or complexity check fails,
    %   NumericComparator delegates comparison to the supplied tolerance.
    %
    %   NumericComparator properties:
    %   	Tolerance  - Optional tolerance object for inexact numerical comparisons.
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (Hidden, Constant, Access=protected)
        % DefaultTolerance - The tolerance that will be used by default
        %   when the 'Within' parameter is not specified by the user.
        DefaultTolerance = [];
    end
    
    methods
        function comparator = NumericComparator(varargin)
            comparator = comparator.parse(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = isa(value, 'numeric');
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            if ~comparator.supports(expVal)
                error(message('MATLAB:unittest:NumericComparator:UnsupportedType'));
            end
            
            isValid = isequal(size(actVal), size(expVal)) && ...
                strcmp(class(actVal), class(expVal)) && ...
                issparse(actVal) == issparse(expVal);
            
            complexityMatches = isreal(actVal) == isreal(expVal);
            
            bool = isValid && complexityMatches && isequaln(expVal, actVal);
            
            if ~bool && isValid && comparator.wasExplicitlySpecified('Within') && comparator.Tolerance.supports(expVal)
                bool = comparator.Tolerance.satisfiedBy(actVal, expVal);
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
                
                % Size check
                if ~isequal(size(actVal), size(expVal))
                    subDiag = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                    % Class check
                elseif ~strcmp(class(actVal), class(expVal))
                    subDiag = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                    % Sparsity check
                elseif issparse(actVal) ~= issparse(expVal)
                    subDiag = ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                    % Complexity check (only applies when no tolerance is supplied)
                elseif ~comparator.wasExplicitlySpecified('Within') && isreal(expVal) ~= isreal(actVal)
                    subDiag = ConstraintDiagnosticFactory.generateComplexityMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                else
                    diag.addCondition(message('MATLAB:unittest:NumericComparator:NotEqual'));
                    if comparator.wasExplicitlySpecified('Within')
                        if comparator.Tolerance.supports(expVal)
                            subDiag = comparator.Tolerance.getDiagnosticFor(actVal, expVal);
                            if isa(subDiag, 'matlab.unittest.diagnostics.ConstraintDiagnostic')
                                subDiag.DisplayActVal = false;
                                subDiag.DisplayExpVal = false;
                            end
                            diag.addCondition(subDiag);
                        else
                            diag.addCondition(message('MATLAB:unittest:NumericComparator:ToleranceNotUsed', class(expVal)));
                        end
                    end
                end
            end
        end
    end
end

% LocalWords:  isequaln
