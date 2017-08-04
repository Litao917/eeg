% This class is undocumented.

% The WithSuffixMixin can be included as a part of class that supports
% specifying a suffix. See HasParserMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2013 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) WithSuffixMixin < matlab.unittest.internal.HasParserMixin
    
    properties (Dependent, SetAccess=private)
        % Suffix - A string to be used as a suffix.
        %
        %   When specified, the instance uses the specified string as a suffix.
        %
        %   The suffix can be specified during construction of the
        %   instance by utilizing the (..., 'WithSuffix', suffix) parameter
        %   value pair.
        Suffix;
    end
    
    properties (Abstract, Hidden, Constant, Access=protected)
        % DefaultSuffix - subclasses of WithSuffixMixin should
        %   define this property to specify the default suffix.
        DefaultSuffix;
    end
    
    methods
        function comp = get.Suffix(mixin)
            % Access the results of the parsing operation
            comp = mixin.ParsingResults.WithSuffix;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = WithSuffixMixin
            % add the WithSuffix parameter value pair and initialize it to the
            % value specified by the subclass
            mixin.addParamValue('WithSuffix',mixin.DefaultSuffix, @validateWithSuffixValue);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = withSuffix(mixin, suffix)
            results = mixin.ExplicitlySpecifiedResults;
            results.WithSuffix = suffix;
            mixin = mixin.parse(results);
        end
    end
end

function bool = validateWithSuffixValue(in)
validateattributes(in, {'char'}, {'row'}, '', 'Suffix');

% Prohibit filesep inside the suffix string.
bool = isempty(strfind(in,filesep));
end