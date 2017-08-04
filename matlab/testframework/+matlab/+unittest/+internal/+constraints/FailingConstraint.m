classdef FailingConstraint < matlab.unittest.constraints.Constraint
    %FAILINGCONSTRAINT This class is a Constraint to be used in the event of
    %unconditional failure. It is utilized by the <qualify>Fail methods.
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function bool = satisfiedBy(~,~)
            bool = false;
        end
        function diag = getDiagnosticFor(~,~)
            diag = matlab.unittest.internal.diagnostics.EmptyDiagnostic;
        end
    end
    
end