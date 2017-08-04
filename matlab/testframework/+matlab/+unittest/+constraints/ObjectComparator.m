classdef ObjectComparator < matlab.unittest.constraints.Comparator & ...
                            matlab.unittest.internal.constraints.WithinMixin
    % ObjectComparator - Comparator for comparing two MATLAB or Java objects.
    %
    %   The ObjectComparator comparator supports any MATLAB or Java object and
    %   performs a comparison by calling the isequal method on the expected value.
    %   An object comparator is satisfied if the isequal method returns true.
    %
    %   When a tolerance is supplied, ObjectComparator first calls the
    %   isequal method of the expected value. If this check fails,
    %   ObjectComparator then checks for equivalent class, size, and
    %   sparsity of the actual and expected values. If these checks fail,
    %   the comparator is not satisfied. If these checks pass,
    %   ObjectComparator delegates comparison to the supplied tolerance.
    %
    %   ObjectComparator properties:
    %   	Tolerance  - Optional tolerance object for inexact numerical comparisons.
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (Hidden, Constant, Access = protected)
        % DefaultTolerance - The tolerance that will be used by default
        %   when the 'Within' parameter is not specified by the user.
        DefaultTolerance = [];
    end
    
    methods
        function obj = ObjectComparator(varargin)
            obj = obj.parse(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = isobject(value) || ...
                isjava(value) || ...
                isa(value, 'function_handle') || ...
                isa(value, 'handle.handle');
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            if (~comparator.supports(expVal))
                error(message('MATLAB:unittest:ObjectComparator:UnsupportedType'));
            end
            
            bool = isequal(expVal, actVal);
            
            % Before applying the tolerance, we check for equivalent size,
            % class, and sparsity because ElementwiseTolerance expects
            % these checks to have already been performed. We might loosen
            % this requirement in the future if use cases are discovered
            % where these checks do not make sense.
            if ~bool && comparator.wasExplicitlySpecified('Within') && ...
                    comparator.Tolerance.supports(expVal) && ...
                    isequal(size(actVal), size(expVal)) && ...
                    strcmp(class(actVal), class(expVal)) && ...
                    issparse(actVal) == issparse(expVal)
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
                hasSupportedTol = comparator.wasExplicitlySpecified('Within') && ...
                    comparator.Tolerance.supports(expVal);
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
                
                % Size check
                if hasSupportedTol && ~isequal(size(actVal), size(expVal))
                    subDiag = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                % Class check
                elseif hasSupportedTol && ~strcmp(class(actVal), class(expVal))
                    subDiag = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                % Sparsity check
                elseif hasSupportedTol && issparse(expVal) ~= issparse(actVal)
                    subDiag = ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(comparator, ...
                        DiagnosticSense.Positive, actVal, expVal);
                    diag.addCondition(subDiag);
                    
                else
                    diag.addCondition(message('MATLAB:unittest:ObjectComparator:NotEqual'));
                    diag.ActValHeader = getString(message('MATLAB:unittest:ObjectComparator:ActualObject'));
                    diag.ExpValHeader = getString(message('MATLAB:unittest:ObjectComparator:ExpectedObject'));
                    
                    if comparator.wasExplicitlySpecified('Within')
                        if comparator.Tolerance.supports(expVal)
                            subDiag = comparator.Tolerance.getDiagnosticFor(actVal, expVal);
                            if isa(subDiag, 'matlab.unittest.diagnostics.ConstraintDiagnostic')
                                subDiag.DisplayActVal = false;
                                subDiag.DisplayExpVal = false;
                            end
                            diag.addCondition(subDiag);
                        else
                            diag.addCondition(message('MATLAB:unittest:ObjectComparator:ToleranceNotUsed', class(expVal)));
                        end
                    end
                end
            end
        end
    end
end

% LocalWords:  Elementwise
