classdef NotConstraint < matlab.unittest.constraints.BooleanConstraint & ...
                         matlab.unittest.internal.constraints.ConciseDiagnosticMixin & ...
                         matlab.unittest.internal.constraints.ConciseNegativeDiagnosticMixin
    % NotConstraint - Boolean complement of a constraint.
    %   A NotConstraint is produced when the "~" operator is used to denote
    %   the complement of a constraint.
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Constraint that is being complemented -- must be NegatableConstraint
        Constraint
    end
    
    methods
        function notConstraint = set.Constraint(notConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.NegatableConstraint'}, ...
                {'scalar'}, '', 'constraint');
            notConstraint.Constraint = constraint;
        end
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.NegatableConstraint)
        function notConstraint = NotConstraint(constraint)
            % Create a new NotConstraint and store the NegatableConstraint to be negated
            notConstraint.Constraint = constraint;
        end
    end
    
    methods
        function tf = satisfiedBy(notConstraint, actual)
            tf = ~notConstraint.Constraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getNegativeDiagnosticFor(actual);
        end
    end
    
    methods (Hidden)
        function diag = getConciseDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getConciseNegativeDiagnosticFor(actual);
        end
        
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getDiagnosticFor(actual);
        end
    end
    
    methods (Access = protected, Hidden)
        function diag = getConciseNegativeDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getConciseDiagnosticFor(actual);
        end        
    end
end
% LocalWords:  Negatable
