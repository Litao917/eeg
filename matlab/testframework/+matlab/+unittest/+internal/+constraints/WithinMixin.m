% This class is undocumented.

% The WithinMixin can be included as a part of class that supports
% specifying a tolerance. See HasParserMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2012 The MathWorks, Inc.
classdef (Hidden) WithinMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % Tolerance - A matlab.unittest.constraints.Tolerance object
        %
        %   When specified, the instance uses the specified tolerance.
        %
        %   The Tolerance property is empty by default, but can be
        %   specified any valid tolerance during construction of the
        %   instance by utilizing the (..., 'Within', tolerance) parameter
        %   value pair.
        Tolerance;
    end
    
    properties (Abstract, Hidden, Constant, Access=protected)
        % DefaultTolerance - subclasses of WithinMixin should
        %   define this property to specify the default tolerance.
        DefaultTolerance;
    end
    
    methods
        function tol = get.Tolerance(mixin)
            % Access the results of the parsing operation
            tol = mixin.ParsingResults.Within;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = WithinMixin
            % add the within parameter value pair and initialize it to empty
            mixin.addParamValue('Within',mixin.DefaultTolerance, @validateWithinValue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = within(mixin, tol)
            results = mixin.ExplicitlySpecifiedResults;
            results.Within = tol;
            mixin = mixin.parse(results);
        end
    end
end

function validateWithinValue(in)
validateattributes(in, ...
    {'matlab.unittest.constraints.Tolerance'}, ...
    {'scalar'}, '', 'Tolerance');
end