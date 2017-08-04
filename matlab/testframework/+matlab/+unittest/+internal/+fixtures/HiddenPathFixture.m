classdef (Hidden) HiddenPathFixture < matlab.unittest.fixtures.PathFixture
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        function fixture = HiddenPathFixture(folder)
            fixture = fixture@matlab.unittest.fixtures.PathFixture(folder);
        end
    end
end