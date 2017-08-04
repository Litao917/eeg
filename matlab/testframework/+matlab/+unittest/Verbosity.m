classdef (Hidden) Verbosity < double
    % This class is undocumented and may change in a future release.
    
    % Verbosity - Specification of level of verbosity.
    %   The matlab.unittest.Verbosity enumeration provides a means to specify
    %   the level of detail related to running tests.
    
    % Copyright 2013 The MathWorks, Inc.
    
    enumeration
        % Terse - The most succinct level.
        Terse (0)
        
        % Concise - A minimal amount of information.
        Concise (1)
        
        % Detailed - Supplemental information.
        Detailed (2)
        
        % Verbose - A surplus of information.
        Verbose (3)
    end
end