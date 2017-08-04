classdef PrintableLoggingStream < matlab.unittest.internal.plugins.Printable
    % Copyright 2012 The MathWorks, Inc.
    
    properties (Dependent)
        Log;
    end
    
    properties
        LoggingStream;
    end
    
    methods
        function printable = PrintableLoggingStream
            loggingStream = matlab.unittest.internal.plugins.LoggingStream();
            printable = printable@matlab.unittest.internal.plugins.Printable(loggingStream);
            printable.LoggingStream = loggingStream;
        end
        
        function log = get.Log(printable)
            log = printable.LoggingStream.Log;
        end
    end
end