classdef AndTolerance < matlab.unittest.internal.constraints.CompositeTolerance
    % AndTolerance - Boolean conjunction of two tolerances.
    %   An AndTolerance is produced when the "&" operator is used to denote
    %   the conjunction of two tolerances.
    
    %  Copyright 2012 The MathWorks, Inc.
    
    properties (Hidden, Constant, GetAccess = protected)
        BooleanOperation = getString(message('MATLAB:unittest:Tolerance:BooleanOperationAnd'));
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.ElementwiseTolerance)
        function andTolerance = AndTolerance(varargin)
            andTolerance = andTolerance@matlab.unittest.internal.constraints.CompositeTolerance(varargin{:});
        end
    end
    
    methods (Access = protected)
        function comp = compareValues(andTolerance, actVal, expVal)
            comp = andTolerance.FirstTolerance.compareValues(actVal, expVal) & ...
                andTolerance.SecondTolerance.compareValues(actVal, expVal);
        end
    end
end