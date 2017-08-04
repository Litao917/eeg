classdef OrConstraint < matlab.unittest.internal.constraints.CombinableConstraint
    % OrConstraint - Boolean disjunction of two constraints.
    %   An OrConstraint is produced when the "|" operator is used to denote
    %   the disjunction of two constraints.
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Left constraint that is being OR'ed -- must be CombinableConstraint
        FirstConstraint
        
        % Right constraint that is being OR'ed -- must be CombinableConstraint
        SecondConstraint
    end
    
    methods
        function orConstraint = set.FirstConstraint(orConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.CombinableConstraint'}, ...
                {'scalar'}, '', 'firstConstraint');
            orConstraint.FirstConstraint = constraint;
        end
        
        function orConstraint = set.SecondConstraint(orConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.CombinableConstraint'}, ...
                {'scalar'}, '', 'secondConstraint');
            orConstraint.SecondConstraint = constraint;
        end
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.CombinableConstraint)
        function orConstraint = OrConstraint(firstConstraint, secondConstraint)
            % This constraint holds onto two constraints and applies OR behavior.
            % Constructor requires two CombinableConstraints.
            orConstraint.FirstConstraint = firstConstraint;
            orConstraint.SecondConstraint = secondConstraint;
        end
    end
    
    methods    
        function tf = satisfiedBy(orConstraint, actual)
            tf = orConstraint.FirstConstraint.satisfiedBy(actual) || ...
                orConstraint.SecondConstraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(orConstraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.indent;
            
            satisfied1 = orConstraint.FirstConstraint.satisfiedBy(actual);
            satisfied2 = orConstraint.SecondConstraint.satisfiedBy(actual);
            
            if (satisfied1 || satisfied2)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    orConstraint, DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    orConstraint, DiagnosticSense.Positive, actual);
                diag.DisplayActVal = false;
            end
            
            diag.DisplayConditions = true;
            
            diag1 = orConstraint.FirstConstraint.getDiagnosticFor(actual);
            diag1.diagnose();
            
            diag2 = orConstraint.SecondConstraint.getDiagnosticFor(actual);
            diag2.diagnose();
            
            indention = ' |   ';
            indented1 = indent(diag1.DiagnosticResult, indention);
            indented2 = indent(diag2.DiagnosticResult, indention);
            
            diag.addCondition(sprintf('%s\n%s', ...
                orConstraint.FirstConditionHeader, indented1));
            diag.addCondition(sprintf('%s\n%s\n%s\n%s', ...
                getString(message('MATLAB:unittest:Constraint:BooleanOr')), ...
                orConstraint.SecondConditionHeader, indented2, ...
                orConstraint.ConditionFooter));
        end
    end
    
    methods (Hidden)
        function constraint = not(orConstraint)
            % Apply De Morgan's law. This will throw an error if either
            % FirstConstraint or SecondConstraint is not Negatable, which
            % is required if the OrConstraint itself is to be negated.
            constraint = ~orConstraint.FirstConstraint & ~orConstraint.SecondConstraint;
        end
    end
end

% LocalWords:  OR'ed Negatable
