classdef (Sealed, Hidden) AliasDecorator < matlab.unittest.internal.constraints.ConstraintDecorator
    % This class is undocumented.
    
    % AliasDecorator - Decorates Constraint's alias
    %
    %   The AliasDecorator decorates a ConstraintDiagnostic obtained from
    %   diagnosing a Constraint with an alias. The specified 'alias'
    %   replaces the default Description of the ConstraintDiagnostic. 
    %   
    %   See also
    %       matlab.unittest.internal.constraints.ConstraintDecorator
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Alias - ConstraintDiagnostic description alias
        Alias;
    end
    
    methods
        function decorator = AliasDecorator(constraint, alias)            
            decorator@matlab.unittest.internal.constraints.ConstraintDecorator(constraint);   
            validateattributes(alias, {'char'}, {'nonempty'}, '', 'Alias');
            decorator.Alias = alias;
        end
        
        function bool = satisfiedBy(decorator, varargin)
            % Pass through to decorated constraint's satisfiedBy()
            bool = decorator.Constraint.satisfiedBy(varargin{:});
        end
        
        function diag = getDiagnosticFor(decorator, varargin)
            import matlab.unittest.internal.diagnostics.createConstraintDiagnosticDescription;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
                        
            isSatisfied = decorator.Constraint.satisfiedBy(varargin{:});
            diag = decorator.Constraint.getDiagnosticFor(varargin{:});
            if metaclass(diag) <= ?matlab.unittest.diagnostics.ConstraintDiagnostic                
                diag.Description = createConstraintDiagnosticDescription(...
                                            decorator, ...
                                            isSatisfied, ...
                                            DiagnosticSense.Positive);
            end
        end
    end        
end