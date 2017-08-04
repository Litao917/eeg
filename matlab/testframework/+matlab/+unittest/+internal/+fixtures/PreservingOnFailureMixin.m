% This class is undocumented.

% The PreservingOnFailureMixin can be included as a part of any class that
% can optionally preserve content after a failure. See HasParserMixin.m for
% details on the process to utilize this mixin.

%  Copyright 2013 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) PreservingOnFailureMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % PreserveOnFailure - determine whether this instance preserves content after a failure
        %
        %   When this value is true, the instance preserves content after a
        %   failure.
        %
        %   The PreserveOnFailure property is false by default, but can be
        %   specified to be true during construction of the instance by utilizing
        %   the (..., 'PreservingOnFailure', true) parameter value pair.
        PreserveOnFailure;
    end
    
    methods
        function tf = get.PreserveOnFailure(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.PreservingOnFailure;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = PreservingOnFailureMixin
            % add the preserving on failure parameter value pair and initialize it to false
            mixin.addParamValue('PreservingOnFailure',false, @validatePreservingOnFailureMixinTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = preservingOnFailure(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.PreservingOnFailure = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validatePreservingOnFailureMixinTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','PreservingOnFailure');
result = in; % only allow setting it to true
end