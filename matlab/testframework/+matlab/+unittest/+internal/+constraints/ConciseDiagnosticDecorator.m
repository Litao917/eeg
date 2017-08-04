classdef (Sealed, Hidden) ConciseDiagnosticDecorator < matlab.unittest.internal.constraints.ConstraintDecorator
    % This class is undocumented.
    
    % ConciseDiagnosticDecorator - Decorates Constraint's diagnostics
    %
    %   The ConciseDiagnosticDecorator is a means to provide concise
    %   diagnostics from a Constraint. A Constraint announces its ability
    %   to provide concise diagnostics by mixing in ConciseDiagnosticMixin
    %   and implementing getConciseDiagnosticFor(). 
    %
    %   The ConciseDiagnosticDecorator is then responsible to return either
    %   concise or full/default diagnostics depending on the decorated
    %   constraint's ability.
    %   
    %   See also
    %       matlab.unittest.internal.constraints.ConstraintDecorator
    %       matlab.unittest.internal.constraints.ConciseDiagnosticMixin
    
    %  Copyright 2013 The MathWorks, Inc. 
    
    methods
        function decorator = ConciseDiagnosticDecorator(constraint)            
            decorator@matlab.unittest.internal.constraints.ConstraintDecorator(constraint);            
        end
        
        function bool = satisfiedBy(decorator, varargin)
            % Pass through to decorated constraint's satisfiedBy()
            bool = decorator.Constraint.satisfiedBy(varargin{:});
        end
        
        function diag = getDiagnosticFor(decorator, varargin)
            import matlab.unittest.internal.diagnostics.createConstraintDiagnosticDescription;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;   
            
            % Return either a concise or full diagnostic depending on the
            % constraint's subscription
            
            % If the constraint being decorated is a NotConstraint, check
            % if the underlying constraint is capable of providing concise
            % diagnostics.
            if metaclass(decorator.Constraint) <= ?matlab.unittest.constraints.NotConstraint
                constraintToCheckForConciseDiagnostic = decorator.Constraint.Constraint;
            else
                constraintToCheckForConciseDiagnostic = decorator.Constraint;
            end
            
            if metaclass(constraintToCheckForConciseDiagnostic) < ?matlab.unittest.internal.constraints.ConciseDiagnosticMixin
                diag = decorator.Constraint.getConciseDiagnosticFor(varargin{:});
            else
                diag = decorator.Constraint.getDiagnosticFor(varargin{:});
            end
        end
    end        
end