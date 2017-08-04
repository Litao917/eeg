classdef Propagates< handle
%matlab.system.mixin.Propagates Mixin to define output attributes 
%   The Propgates mixin is a base class for System objects that defines
%   the System object's output size, data type, and complexity.  Implement
%   the methods of this class when output specifications cannot be
%   inferred directly from the inputs in the MATLAB System Block during
%   Simulink model compilation.
%   
%   To use this mixin, subclass your object from this class in addition 
%   to the matlab.System base class. Use the following syntax as the first
%   line of your class definition file,  where ObjectName is the name of
%   your object:
%   
%   classdef ObjectName < matlab.System &...    
%       matlab.system.mixin.Propagates

 
%   Copyright 2012-2014 The MathWorks, Inc.

    methods
        function out=Propagates
            %matlab.system.mixin.Propagates Mixin to define output attributes 
            %   The Propgates mixin is a base class for System objects that defines
            %   the System object's output size, data type, and complexity.  Implement
            %   the methods of this class when output specifications cannot be
            %   inferred directly from the inputs in the MATLAB System Block during
            %   Simulink model compilation.
            %   
            %   To use this mixin, subclass your object from this class in addition 
            %   to the matlab.System base class. Use the following syntax as the first
            %   line of your class definition file,  where ObjectName is the name of
            %   your object:
            %   
            %   classdef ObjectName < matlab.System &...    
            %       matlab.system.mixin.Propagates
        end

        function getOutputDataTypeImpl(in) %#ok<MANU>
        end

        function getOutputSizeImpl(in) %#ok<MANU>
        end

        function isOutputComplexImpl(in) %#ok<MANU>
        end

        function isOutputFixedSizeImpl(in) %#ok<MANU>
        end

    end
    methods (Abstract)
    end
end
