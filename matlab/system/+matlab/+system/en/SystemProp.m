classdef SystemProp< handle
%  FOR INTERNAL USE ONLY -- This class is intentionally undocumented. Its
%  behavior may change, or the class itself may be removed in a future
%  release.

   
  %   Copyright 1995-2013 The MathWorks, Inc.

    methods
        function out=SystemProp
            % Property management base class for System objects
        end

        function getInputNames(in) %#ok<MANU>
            %getInputNames   Returns input names
            %   [N1, N2, ...] = getInputNames(OBJ) returns input names, where the
            %   number of names returned matches the number of inputs for OBJ.
            %
            %   Changing the property values of OBJ can change the number of inputs
            %   and the names of those inputs.
        end

        function getInputNamesImpl(in) %#ok<MANU>
        end

        function getOutputNames(in) %#ok<MANU>
            %getOutputNames   Returns output names
            %   [N1, N2, ...] = getOutputNames(OBJ) returns output names, where the
            %   number of names returned matches the number of outputs for OBJ.
            %
            %   Changing the property values of OBJ can change the number of outputs
            %   ands the names of those outputs.
        end

        function getOutputNamesImpl(in) %#ok<MANU>
        end

        function isInactivePropertyImpl(in) %#ok<MANU>
            %flag = isInactivePropertyImpl(obj, prop) Whether prop is currently 'on'
            %   Return a flag indicating if input prop is 'turned off' or irrelevant
            %   based on the current property values.
        end

    end
    methods (Abstract)
    end
end
