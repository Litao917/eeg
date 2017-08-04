classdef OrTolerance < matlab.unittest.internal.constraints.CompositeTolerance
    % OrTolerance - Boolean disjunction of two tolerances.
    %   An OrTolerance is produced when the "|" operator is used to denote
    %   the disjunction of two tolerances.
    
    %  Copyright 2012 The MathWorks, Inc.
    
    properties (Hidden, Constant, GetAccess = protected)
        BooleanOperation = getString(message('MATLAB:unittest:Tolerance:BooleanOperationOr'));
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.ElementwiseTolerance)
        function orTolerance = OrTolerance(varargin)
            orTolerance = orTolerance@matlab.unittest.internal.constraints.CompositeTolerance(varargin{:});
        end
    end
    
    methods (Access = protected)
        function comp = compareValues(orTolerance, actVal, expVal)
            comp = orTolerance.FirstTolerance.compareValues(actVal, expVal) | ...
                orTolerance.SecondTolerance.compareValues(actVal, expVal);
        end
    end
end