% This class is undocumented.

% The CausedByMixin can be included as a part of any class that requires
% specifying causes of an action. See HasParserMixin.m for details on the
% process to utilize this mixin.

%  Copyright 2013 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) CausedByMixin < matlab.unittest.internal.HasParserMixin
    properties (Dependent, SetAccess=private)
        % RequiredCauses - specifies the causes to look for
        %
        %   The RequiredCauses value can be cell array of Strings or meta.classes 
        %   or any combination of these or empty cell.
        %
        %   This property is read only and can only be set through the constructor.
        RequiredCauses;
    end
    
    methods
        function tf = get.RequiredCauses(mixin)
            % Access the results of the parsing operation
            tf = mixin.ParsingResults.CausedBy;
        end
    end
    
    methods (Hidden, Access=protected)
        function mixin = CausedByMixin
            % CausedBy is parameter value pair and initialize
            % it to {}
            mixin.addParamValue('CausedBy',{}, @validateCausedBy);
        end
    end
end

function validateCausedBy(in)
    validateattributes(  ...
        in,{'cell'},{},'', 'CausedBy');

    cellfun(@(element) validateattributes( element, ...
        {'meta.class', 'char', 'message'}, ...
        {}),...
        in);
end