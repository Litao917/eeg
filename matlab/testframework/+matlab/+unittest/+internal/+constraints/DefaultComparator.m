% This class is undocumented.

% DefaultComparator - A concrete Comparator implementation
%
%   The DefaultComparator class is a Comparator implementation which
%   provides no actual comparison capability.

%  Copyright 2012 The MathWorks, Inc.

classdef DefaultComparator < matlab.unittest.constraints.Comparator
    methods
        function diag = getDiagnosticFor(~, ~, ~)
            diag = matlab.unittest.internal.diagnostics.EmptyDiagnostic;
        end
        
        function bool = satisfiedBy(~, ~)
            bool = false;
        end
        
        function bool = supports(~, ~)
            bool = false;
        end
    end
end