% This class is undocumented.

% The IncludingAssumptionFailuresMixin can be included as a part of any
% class that can optionally react to assumption failures. See
% HasParserMixin.m for details on the process to utilize this mixin.

%  Copyright 2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) IncludingAssumptionFailuresMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % IncludeAssumptionFailures - determine whether this instance reacts to assumption failures
        %
        %   When this value is true, the instance reacts to assumption
        %   failures. When it is false, the instance ignores assumption failures.
        %
        %   The IncludeAssumptionFailures property is false by default, but
        %   can be specified to be true during construction of the instance
        %   by utilizing the (..., 'IncludingAssumptionFailures', true)
        %   parameter value pair.
        IncludeAssumptionFailures;
    end
    
    methods
        function tf = get.IncludeAssumptionFailures(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.IncludingAssumptionFailures;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = IncludingAssumptionFailuresMixin
            % add the including assumption failures parameter value pair and initialize it to false
            mixin.addParamValue('IncludingAssumptionFailures',false, @validateIncludingAssumptionFailuresTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = includingAssumptionFailures(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.IncludingAssumptionFailures = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateIncludingAssumptionFailuresTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','IncludingAssumptionFailures');
result = in; % only allow setting it to true
end