% This class is undocumented.

% The ExactlyMixin can be included as a part of any class that can
% conditionally respect set elements. See HasParserMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2011-2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) ExactlyMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % Exact - specifies whether this instance performs exact comparisons
        %
        %   When this value is true, the instance is sensitive to all ignorable
        %   differences and respects all applicable variations. When it is false,
        %   the instance relies on specification of other parameters and default
        %   instance behavior in order to determine the strictness of its
        %   comparison.
        %
        %   The Exact property is false by default, but can be specified to
        %   be true during construction of the instance by utilizing the
        %   (..., 'Exactly', true) parameter value pair.
        Exact;
    end
    
    methods
        function tf = get.Exact(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.Exactly;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = ExactlyMixin
            % add the exactly parameter value pair and initialize it to false
            mixin.addParamValue('Exactly',false, @validateExactlyTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = exactly(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.Exactly = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateExactlyTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','Exactly');
result = in; % only allow setting it to true
end