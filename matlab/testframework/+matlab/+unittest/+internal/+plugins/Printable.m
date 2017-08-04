classdef(Abstract, Hidden, HandleCompatible) Printable
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    properties(Access=private)
        OutputStream
    end
    
    methods(Hidden, Access=protected)
        function printable = Printable(outputStream)
            import matlab.unittest.plugins.ToStandardOutput;
            
            if nargin > 0
                printable.OutputStream = outputStream;
            else
                printable.OutputStream = ToStandardOutput;
            end
        end
        
        function print(plugin, varargin)
            plugin.OutputStream.print(varargin{:});
        end
        
        function printEmptyLine(plugin)
            plugin.printLine('');
        end
        
        function printLine(plugin, str)
            plugin.print('%s\n', str);
        end
        
        function bool = isUsingStandardOutputStream(plugin)
            bool = isa(plugin.OutputStream, 'matlab.unittest.plugins.ToStandardOutput');
        end
    end
end
