% This class is undocumented.

% The RecursivelyMixin can be included as a part of any class that can
% compare data structures recursively. See HasParserMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2012 The MathWorks, Inc.
classdef (Hidden) RecursivelyMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % Recursive - determine whether a this instance recurses on its data
        %
        %   When this value is true, the instance recursively compares
        %   its contained data. When it is false, the instance does not
        %   recurse on its contained data.
        %
        %   The Recursive property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'Recursively', true) parameter value pair.
        Recursive;
    end
    
    methods
        function tf = get.Recursive(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.Recursively;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = RecursivelyMixin
            % add the recursively parameter value pair and initialize it to false
            mixin.addParamValue('Recursively',false, @validateRecursivelyTrue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = recursively(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.Recursively = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateRecursivelyTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','Recursively');
result = in; % only allow setting it to true
end