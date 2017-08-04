classdef FiniteSource< handle
%matlab.system.mixin.FiniteSource Mixin for source System objects
%   The FiniteSource mixin is a base class for System objects that stream
%   data for a finite duration.  This mixin enables the isDone method. 
%
%   To use this mixin, subclass your object from this 
%   class in addition to the matlab.System base class. Use the
%   following syntax as the first line of your class definition file, 
%   where ObjectName is the name of your object:
%
%   classdef ObjectName < matlab.System &...
%       matlab.system.mixin.FiniteSource

     
%   Copyright 1995-2014 The MathWorks, Inc.

    methods
        function out=FiniteSource
            %matlab.system.mixin.FiniteSource Mixin for source System objects
            %   The FiniteSource mixin is a base class for System objects that stream
            %   data for a finite duration.  This mixin enables the isDone method. 
            %
            %   To use this mixin, subclass your object from this 
            %   class in addition to the matlab.System base class. Use the
            %   following syntax as the first line of your class definition file, 
            %   where ObjectName is the name of your object:
            %
            %   classdef ObjectName < matlab.System &...
            %       matlab.system.mixin.FiniteSource
        end

        function isDone(in) %#ok<MANU>
            %isDone  True if System object has reached end-of-data
            %   isDone(OBJ) returns true if the source System object, OBJ, has
            %   reached the end of the source data (usually a file). For System
            %   objects that can loop, that is, read more than once, this method
            %   returns true every time the end is reached. For source System
            %   objects that do not have a concept of 'end of data', such as a
            %   live microphone feed, the isDone method always returns false. For
            %   object specific information, refer to the help on the isDoneImpl
            %   method of that object.
        end

        function isDoneImpl(in) %#ok<MANU>
        end

    end
    methods (Abstract)
    end
end
