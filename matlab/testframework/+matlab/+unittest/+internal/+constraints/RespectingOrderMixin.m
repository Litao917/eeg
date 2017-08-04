% This class is undocumented.

% The RespectingOrderMixin can be included as a part of any class that can
% conditionally respect set elements. See HasParserMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2010-2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingOrderMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % RespectOrder - specifies whether this instance respects the order of elements
        %
        %   When this value is true, the instance is sensitive to the order of the
        %   set members it applies to. When it is false, the instance is
        %   insensitive to the order of the set members and it is ignored.
        %
        %   The RespectOrder property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'RespectingOrder', true) parameter value pair.
        RespectOrder;
    end
    
    methods
        function tf = get.RespectOrder(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.RespectingOrder;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = RespectingOrderMixin
            % add the respecting order parameter value pair and initialize it to false
            mixin.addParamValue('RespectingOrder',false, @validateRespectingOrderTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingOrder(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.RespectingOrder = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateRespectingOrderTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','RespectingOrder');
result = in; % only allow setting it to true
end