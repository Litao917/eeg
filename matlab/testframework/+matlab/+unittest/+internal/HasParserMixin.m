% This class is undocumented.

% The HasParserMixin class is a base class for use when creating a mixin
% class that adds input parameters to a class constructor. When mixin
% classes inherit from this class they can add input parameters to the one
% parser contained here so that these mixins can be easily utilized in the
% classes that contain the mixins. The process is:
%
%   1) mixin classes derive from this class and add their own input
%   parameters using the addParamValue method.
%   2) mixin classes create Dependent properties to store the values
%   potentially added through param values. The get methods for these
%   dependent properties simply query the ParsingResults property.
%   3) concrete classes derive from one or more mixin class and parse the
%   varargin of their constructor using the parse method.

%  Copyright 2010-2013 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) HasParserMixin
    properties (Access = private)
        Parser = inputParser.empty;
        UsingDefaults;
    end
    
    properties (Constant, Access = private)
        % Create and cache the inputParser at class load time and simply
        % make a copy each time we need to use it. This saves the cost of
        % constructing a new inputParser each time a class which ISA
        % HasParserMixin is constructed.
        DefaultInputParser = generateDefaultInputParser();
    end
    
    properties (Dependent, Hidden, GetAccess = protected, SetAccess = private)
        % ExplicitlySpecifiedResults - This property returns a results
        %   structure which only contains those inputs which have been
        %   explicitly supplied. This is useful when you would like to
        %   re-parse the results, but a default property fails validation.
        ExplicitlySpecifiedResults;
    end
        
    properties (Hidden, GetAccess = protected, SetAccess = private)
        % ParsingResults - This property contains the results of the parsing operation.
        ParsingResults;
    end
    
    methods
        function results = get.ExplicitlySpecifiedResults(mixin)
            notSpecified = mixin.UsingDefaults;
            results = mixin.ParsingResults;
            results = rmfield(results, notSpecified);
        end
    end
    
    methods (Hidden, Access = protected)
        function mixin = HasParserMixin
            % Must only do this once per instance; when multiply inherited
            % the constructor gets called multiple times potentially.
            if isempty(mixin.Parser)
                mixin.Parser = mixin.DefaultInputParser.copy();
            end
        end
        
        function bool = wasExplicitlySpecified(mixin, option)
            % Return a boolean indicating whether the user has explicitly
            % specified an option.
            
            bool = ~any(strcmp(mixin.UsingDefaults, option));
        end
        
        function addParamValue(mixin, varargin)
            % Simple wrapper for the inputParser's addParamValue method.
            
            mixin.Parser.addParamValue(varargin{:});
        end
        
        function addOptional(mixin, varargin)
            % Simple wrapper for the inputParser's addOptional method.
            
            mixin.Parser.addOptional(varargin{:});
        end
        
        function addRequired(mixin, varargin)
            % Simple wrapper for the inputParser's addRequired method.
            
            mixin.Parser.addRequired(varargin{:});
        end
        
        function mixin = parse(mixin, varargin)
            % Wrapper for the inputParser's parse method.
            
            % Because inputParser is a handle class, make a copy of the
            % Parser before (re)parsing. This keeps each instance's copy of
            % the inputParser independent and maintains value semantics.
            mixin.Parser = mixin.Parser.copy();
            
            mixin.Parser.parse(varargin{:});
            mixin.ParsingResults = mixin.Parser.Results;
            mixin.UsingDefaults = mixin.Parser.UsingDefaults;
        end
    end
end

function parser = generateDefaultInputParser()
parser = inputParser;
parser.CaseSensitive = true;
parser.PartialMatching = false;
end