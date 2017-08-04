classdef QualificationFailedException < MException
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods (Access=protected)
        function me = QualificationFailedException(id, message, varargin)
            me = me@MException(id, message, varargin{:});
        end
        
        function stack = getStack(exception)
            import matlab.unittest.internal.trimStackStart;
            import matlab.unittest.internal.trimStackEnd;
            
            stack = exception.getStack@MException;
            stack = trimStackStart(stack);
            stack = trimStackEnd(stack);
        end
        
    end
        
end
