% This class is undocumented.

% The IgnoringWhitespaceMixin can be included as a part of any class that can
% ignore whitespace differences. See HasParserMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2012 The MathWorks, Inc.
classdef (Hidden) IgnoringWhitespaceMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % IgnoreWhitespace - determine whether this instance is insensitive to whitespace
        %
        %   When this value is true, the instance is insensitive to
        %   whitespace differences. When it is false, the instance is
        %   sensitive to whitespace. Whitespace characters are space, form
        %   feed, new line, carriage return, horizontal tab, and vertical tab.
        %
        %   The IgnoreWhitespace property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'IgnoringWhitespace', true) parameter value pair.
        IgnoreWhitespace;
    end
    
    methods
        function tf = get.IgnoreWhitespace(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.IgnoringWhitespace;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = IgnoringWhitespaceMixin
            % add the ignoring whitespace parameter value pair and initialize it to false
            mixin.addParamValue('IgnoringWhitespace',false, @validateIgnoringWhitespaceTrue);
        end
        
        function whitespaceFreeStr = removeWhitespaceFrom(~, str)
            % removeWhitespaceFrom - Remove whitespace characters from a string
            %   This method is provided for convenience because most
            %   subclasses will need to remove whitespace from a string.
            %   Note that regexprep is used which also validates that the
            %   string is a 1-D row array. Removing whitespace from a
            %   non-vector string is ill defined.
            
            whitespaceFreeStr = regexprep(str, '\s', '');
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = ignoringWhitespace(mixin)
            results = mixin.ExplicitlySpecifiedResults;
            results.IgnoringWhitespace = true;
            mixin = mixin.parse(results);
        end
    end
end

function result = validateIgnoringWhitespaceTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','IgnoringWhitespace');
result = in; % only allow setting it to true
end