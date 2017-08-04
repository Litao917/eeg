classdef SharedTestFixturePluginData < matlab.unittest.plugins.plugindata.PluginData
    % SharedTestFixturePluginData - Data about shared test fixtures.
    %
    %   The SharedTestFixturePluginData class holds information about
    %   shared test fixtures.
    %
    %   SharedTestFixturePluginData properties:
    %       Name        - Name of shared test fixture.
    %       Description - Action performed by the shared fixture.
    %
    %   See also: matlab.unittest.plugins.TestRunnerPlugin, matlab.unittest.fixtures.Fixture
    %
    
    %  Copyright 2013 The MathWorks, Inc.
    
    
    properties (SetAccess = ?matlab.unittest.TestRunner)
        % Description - Action performed by the shared fixture.
        %
        %   The Description property is a string which contains information about
        %   the actions performed during the setup or teardown of a shared test
        %   fixture.
        Description = '';
    end
    
    methods (Access = {?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.SharedTestFixturePluginData})
        function p = SharedTestFixturePluginData(name, description)
            p@matlab.unittest.plugins.plugindata.PluginData(name);
            if nargin == 2
                p.Description = description;
            end
        end
    end
    
end

% LocalWords:  plugindata
