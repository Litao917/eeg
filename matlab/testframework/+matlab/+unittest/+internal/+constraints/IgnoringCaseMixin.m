% This class is undocumented.

% The IgnoringCaseMixin can be included as a part of any class that can
% ignore case differences. See HasParserMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2010-2012 The MathWorks, Inc.
classdef (Hidden) IgnoringCaseMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % IgnoreCase - determine whether this instance is insensitive to case
        %
        %   When this value is true, the instance is insensitive to case
        %   differences. When it is false, the instance is sensitive to case.
        %
        %   The IgnoreCase property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'IgnoringCase', true) parameter value pair.
        IgnoreCase;
    end
    
    methods
        function tf = get.IgnoreCase(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.IgnoringCase;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = IgnoringCaseMixin
            % add the ignoring case parameter value pair and initialize it to false
            mixin.addParamValue('IgnoringCase',false, @validateIgnoringCaseTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = ignoringCase(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.IgnoringCase = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateIgnoringCaseTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','IgnoringCase');
result = in; % only allow setting it to true
end