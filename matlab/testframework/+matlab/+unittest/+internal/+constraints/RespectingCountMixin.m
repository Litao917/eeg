% This class is undocumented.

% The RespectingCountMixin can be included as a part of any class that can
% conditionally respect the number of occurrences of elements. See
% HasParserMixin.m for details on the process to utilize this mixin.

%  Copyright 2011-2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingCountMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % RespectCount - specifies whether this instance respects element counts
        %
        %   When this value is true, the instance is sensitive to the total number
        %   of set members. When it is false, the instance is insensitive to
        %   the number of occurrences of members and their frequency is ignored.
        %
        %   The RespectCount property is false by default, but can be specified to be
        %   true during construction of the instance by utilizing the
        %   (..., 'RespectingCount', true) parameter value pair.
        RespectCount;
    end
    
    methods
        function tf = get.RespectCount(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.RespectingCount;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = RespectingCountMixin
            % add the respecting count parameter value pair and initialize it to false
            mixin.addParamValue('RespectingCount',false, @validateRespectingCountTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingCount(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.RespectingCount = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateRespectingCountTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','RespectingCount');
result = in; % only allow setting it to true
end