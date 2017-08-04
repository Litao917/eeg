classdef (Hidden) Comparator < matlab.mixin.Heterogeneous
    % Comparator - Abstract interface for comparators.
    %
    %   Comparators define a notion of equality for a set of data types and can be
    %   plugged in to the IsEqualTo constraint.
    %
    %   Comparator methods:
    %       supports         - Returns a boolean value indicating whether the comparator supports a specified data type.
    %       satisfiedBy      - Returns a boolean value indicating whether the comparator was satisfied by two values.
    %       getDiagnosticFor - Returns a diagnostic object containing information about the result of a comparison.
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    methods (Hidden = true, Access = protected)
         function comp = Comparator()
         end
    end

    methods (Abstract)
        % supports - Returns a boolean value indicating whether the comparator supports a specified data type.
        %
        %   The supports method is meant to provide the comparator the opportunity
        %   to specify support for data types. The method is meant to operate by
        %   examining the type of <value> to determine whether it is supported.
        bool = supports(comp, value);
        
        % satisfiedBy - Returns a boolean value indicating whether the comparator was satisfied by two values.
        %
        %   This method defines the comparators notion of equality. If a comparator
        %   has been satisfied, it indicates that the comparator considers the two
        %   values equivalent.
        bool = satisfiedBy(comp, actVal, expVal);
        
        % getDiagnosticFor - Returns a diagnostic object containing information about the result of a comparison.
        %
        %   Analyzes the actual and expected values and produces a 
        %   matlab.unittest.diagnostics.ConstraintDiagnostic object containing 
        %   information about the comparison performed.
        %
        %   See also:
        %       matlab.unittest.diagnostics.ConstraintDiagnostic
        diag = getDiagnosticFor(comp, actVal, expVal);
    end
    
    methods (Hidden = true, Sealed = true, Static = true, Access = protected)
        function instance = getDefaultScalarElement
            instance = matlab.unittest.internal.constraints.DefaultComparator;
        end
    end
end