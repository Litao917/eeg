classdef (Hidden) DetailedProgressPlugin < matlab.unittest.plugins.TestRunProgressPlugin
    % This class is undocumented and may change in a future release.
    
    % DetailedProgressPlugin - Plugin which outputs detailed test run progress.
    % 
    %   The DetailedProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods (Access=?matlab.unittest.plugins.TestRunProgressPlugin)
        function plugin = DetailedProgressPlugin(varargin)
            plugin@matlab.unittest.plugins.TestRunProgressPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupSharedTestFixture(plugin, pluginData)
            plugin.printLine(plugin.Catalog.getString('SettingUp', pluginData.Name));
            
            setupSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            description = plugin.Catalog.getString('DoneSettingUp', pluginData.Name);
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.printLine(description);
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            plugin.printLine(plugin.Catalog.getString('TearingDown', pluginData.Name));
            
            teardownSharedTestFixture@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            
            description = plugin.Catalog.getString('DoneTearingDown', pluginData.Name);
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.printLine(description);
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end
        
        function runTestClass(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.indent;
            
            plugin.printLine(indent(plugin.Catalog.getString('Running', pluginData.Name), ' '));
            runTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            plugin.printLine(indent(plugin.Catalog.getString('Done', pluginData.Name), ' '));
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end
        
        function setupTestClass(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.indent;
            
            plugin.printLine(indent(plugin.Catalog.getString('SettingUp', pluginData.Name), '  '));
            setupTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            plugin.printLine(indent(plugin.Catalog.getString('DoneSettingUp', pluginData.Name), '  '));
        end
        
        function teardownTestClass(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.indent;
            
            plugin.printLine(indent(plugin.Catalog.getString('TearingDown', pluginData.Name), '  '));
            teardownTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            plugin.printLine(indent(plugin.Catalog.getString('DoneTearingDown', pluginData.Name), '  '));
        end
        
        function runTest(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.indent;
            
            plugin.printLine(indent(plugin.Catalog.getString('Running', pluginData.Name), '   '));
            runTest@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            plugin.printLine(indent(plugin.Catalog.getString('Done', pluginData.Name), '   '));
        end
    end
end