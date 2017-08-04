classdef TrimmedException < MException
% This class is undocumented.

%  Copyright 2013 MathWorks, Inc. 
    
    properties(Access=private)
        LongException
    end
    
    methods
        function trimmed = TrimmedException(other)
            trimmed = trimmed@MException(other.identifier, '%s', other.message);
            trimmed.LongException = other;
            trimmed.type = other.type;
            for idx = 1:numel(other.cause)
                trimmed = trimmed.addCause(other.cause{idx});
            end
        end
    end
    
    methods(Access=protected)
        function stack = getStack(trimmed)
            import matlab.unittest.internal.trimStackEnd;
            
            stack = trimmed.LongException.getStack;
            stack = trimStackEnd(stack);
        end      
    end         
    
end
