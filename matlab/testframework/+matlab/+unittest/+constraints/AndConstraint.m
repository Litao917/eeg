classdef AndConstraint < matlab.unittest.internal.constraints.CombinableConstraint
    % AndConstraint - Boolean conjunction of two constraints.
    %   An AndConstraint is produced when the "&" operator is used to
    %   denote the conjunction of two constraints.
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Left constraint that is being AND'ed -- must be CombinableConstraint
        FirstConstraint
        
        % Right constraint that is being AND'ed -- must be CombinableConstraint
        SecondConstraint
    end
    
    methods
        function andConstraint = set.FirstConstraint(andConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.CombinableConstraint'}, ...
                {'scalar'}, '', 'firstConstraint');
            andConstraint.FirstConstraint = constraint;
        end
        
        function andConstraint = set.SecondConstraint(andConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.CombinableConstraint'}, ...
                {'scalar'}, '', 'secondConstraint');
            andConstraint.SecondConstraint = constraint;
        end
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.CombinableConstraint)
        function andConstraint = AndConstraint(firstConstraint, secondConstraint)
            % This constraint holds onto two constraints and applies AND behavior.
            % Constructor requires two CombinableConstraints.
            andConstraint.FirstConstraint = firstConstraint;
            andConstraint.SecondConstraint = secondConstraint;
        end
    end
    
    methods
        function tf = satisfiedBy(andConstraint, actual)
            tf = andConstraint.FirstConstraint.satisfiedBy(actual) && ...
                andConstraint.SecondConstraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(andConstraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.indent;
            
            satisfied1 = andConstraint.FirstConstraint.satisfiedBy(actual);
            satisfied2 = andConstraint.SecondConstraint.satisfiedBy(actual);
            
            if (satisfied1 && satisfied2)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    andConstraint, DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    andConstraint, DiagnosticSense.Positive, actual);
                diag.DisplayActVal = false;
            end
            diag.DisplayConditions = true;
                       
            diag1 = andConstraint.FirstConstraint.getDiagnosticFor(actual);
            diag1.diagnose();
            
            diag2 = andConstraint.SecondConstraint.getDiagnosticFor(actual);
            diag2.diagnose();
            
            indention = ' |   ';
            indented1 = indent(diag1.DiagnosticResult, indention);
            indented2 = indent(diag2.DiagnosticResult, indention);
            
            diag.addCondition(sprintf('%s\n%s', ...
                andConstraint.FirstConditionHeader, indented1));
            diag.addCondition(sprintf('%s\n%s\n%s\n%s', ...
                getString(message('MATLAB:unittest:Constraint:BooleanAnd')), ...
                andConstraint.SecondConditionHeader, indented2, ...
                andConstraint.ConditionFooter));
        end
    end
    
    methods (Hidden)
        function constraint = not(andConstraint)
            % Apply De Morgan's law. This will throw an error if either
            % FirstConstraint or SecondConstraint is not Negatable, which
            % is required if the AndConstraint itself is to be negated.
            constraint = ~andConstraint.FirstConstraint | ~andConstraint.SecondConstraint;
        end
    end
end

% LocalWords:  AND'ed Negatable
