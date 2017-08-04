% This class is undocumented.

% The WhenNargoutIsMixin can be included as a part of any class that can
% execute functions while specifying a number of outputs. See
% HasParserMixin.m for details on the process to utilize this mixin.

%  Copyright 2011-2012 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) WhenNargoutIsMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % Nargout - specifies the number of outputs this instance should supply
        %
        %   The Nargout value can be a non-negative real scalar integer. It
        %   determines the number of output arguments the instance will use
        %   when executing functions.
        %
        %   The Nargout property is 0 by default, but can be specified to
        %   be a higher value during construction of the instance by
        %   utilizing the (..., 'WhenNargoutIs', N) parameter value pair,
        %   which applies N output arguments.
        Nargout;
    end
    
    methods
        function tf = get.Nargout(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.WhenNargoutIs;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = WhenNargoutIsMixin
            % add the when nargout is parameter value pair and initialize it to false
            mixin.addParamValue('WhenNargoutIs',0, @validateWhenNargoutIs);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = whenNargoutIs(mixin, value)
            results = mixin.ExplicitlySpecifiedResults;
            results.WhenNargoutIs = value;
            mixin = mixin.parse(results);
        end
    end
end

function validateWhenNargoutIs(in)
validateattributes(in, ...
    {'numeric'}, {'scalar','nonnegative','integer','real'}, '', 'Nargout');
end