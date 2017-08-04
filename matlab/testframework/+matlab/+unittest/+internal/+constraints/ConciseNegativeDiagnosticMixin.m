classdef (Hidden, Abstract, HandleCompatible) ConciseNegativeDiagnosticMixin 
    % This class is undocumented.
    
    %   The ConciseDiagnosticMixin can be included as a part of Constraint
    %   class that supports providing concise diagnostics. A Constraint
    %   inheriting from this mixin must implement getConciseDiagnosticFor()
    %
    %   See also
    %       matlab.unittest.internal.constraints.ConciseDiagnosticDecorator
    %       matlab.unittest.internal.constraints.ConciseDiagnosticMixin
    
    %  Copyright 2013 The MathWorks, Inc.
    
    methods (Abstract, Access = protected, Hidden)
        % Method responsible to provide concise negative constraint diagnostics
        diag = getConciseNegativeDiagnosticFor(constraint, actual)
    end
end