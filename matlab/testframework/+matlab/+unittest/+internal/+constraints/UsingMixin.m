% This class is undocumented.

% The UsingMixin can be included as a part of class that supports
% specifying a comparator. See HasParserMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2012 The MathWorks, Inc.
classdef (Hidden) UsingMixin < matlab.unittest.internal.HasParserMixin
    
    properties (Dependent, SetAccess=private)
        % Comparator - A matlab.unittest.constraints.Comparator object
        %
        %   When specified, the instance uses the specified comparator.
        %
        %   The comparator can be specified during construction of the
        %   instance by utilizing the (..., 'Using', comparator) parameter
        %   value pair.
        Comparator;
    end
    
    properties (Abstract, Hidden, Constant, Access=protected)
        % DefaultComparator - subclasses of UsingMixin should
        %   define this property to specify the default comparator.
        DefaultComparator;
    end
    
    methods
        function comp = get.Comparator(mixin)
            % Access the results of the parsing operation            
            if mixin.wasExplicitlySpecified('Using')
                comp = mixin.ParsingResults.Using;
            else
                comp = mixin.DefaultComparator;                
            end
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = UsingMixin
            % add the using parameter value pair and initialize it to the
            % value specified by the subclass
            mixin.addParamValue('Using', [], @validateUsingValue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = using(mixin, comp)
            results = mixin.ExplicitlySpecifiedResults;
            results.Using = comp;
            mixin = mixin.parse(results);
        end
    end
end

function validateUsingValue(in)
validateattributes(in, ...
    {'matlab.unittest.constraints.Comparator'}, ...
    {'scalar'}, '', 'Comparator');
end