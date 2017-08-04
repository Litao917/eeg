classdef StandardOutputStream 
    % Obsolete.
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    methods(Static)
        function stream = loadobj(~)
            stream = matlab.unittest.plugins.ToStandardOutput();
        end
    end
end




