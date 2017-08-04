classdef LoggingStream < matlab.unittest.plugins.OutputStream
    % OutputStream that logs all text sent to it
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    properties
        Log = '';
    end
    
    
    methods
        function print(stream, formatStr, varargin)
            stream.Log = [stream.Log, sprintf(formatStr, varargin{:})];
        end
    end
end




