% This class is undocumented.

% The RespectingSetMixin can be included as a part of any class that can
% conditionally respect set elements. See HasParserMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2010-2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingSetMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % RespectSet - specifies whether this instance respects set elements
        %
        %   When this value is true, the instance is sensitive to additional set
        %   members. When it is false, the instance is insensitive to additional
        %   set members and they are ignored.
        %
        %   The RespectSet property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'RespectingSet', true) parameter value pair.
        RespectSet;
    end
    
    methods
        function tf = get.RespectSet(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.RespectingSet;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = RespectingSetMixin
            % add the respecting set parameter value pair and initialize it to false
            mixin.addParamValue('RespectingSet',false, @validateRespectingSetTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingSet(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.RespectingSet = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateRespectingSetTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','RespectingSet');
result = in; % only allow setting it to true
end