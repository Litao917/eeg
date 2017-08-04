classdef (Hidden) HiddenCurrentFolderFixture < matlab.unittest.fixtures.CurrentFolderFixture
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        function fixture = HiddenCurrentFolderFixture(folder)
            fixture = fixture@matlab.unittest.fixtures.CurrentFolderFixture(folder);
        end
    end
end