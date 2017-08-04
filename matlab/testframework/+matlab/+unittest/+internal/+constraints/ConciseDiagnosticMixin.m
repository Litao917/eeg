classdef (Hidden, Abstract, HandleCompatible) ConciseDiagnosticMixin
    % This class is undocumented.
    
    %   The ConciseDiagnosticMixin can be included as a part of Constraint
    %   class that supports providing concise diagnostics. A Constraint
    %   inheriting from this mixin must implement getConciseDiagnosticFor()
    %
    %   See also
    %       matlab.unittest.internal.constraints.ConciseDiagnosticDecorator
    
    %  Copyright 2013 The MathWorks, Inc.
    
    methods (Abstract, Hidden)
        % Method responsible to provide concise constraint diagnostics
        diag = getConciseDiagnosticFor(constraint, actual)
    end
end