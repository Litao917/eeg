classdef (Hidden) ConciseProgressPlugin < matlab.unittest.plugins.TestRunProgressPlugin
    % This class is undocumented and may change in a future release.
    
    % ConciseProgressPlugin - Plugin which outputs test run progress.
    % 
    %   The ConciseProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties(Access=private)
        MethodCount = 0;
        NeedNewline = false;
    end
    
    methods (Access=?matlab.unittest.plugins.TestRunProgressPlugin)
        function plugin = ConciseProgressPlugin(varargin)
            plugin@matlab.unittest.plugins.TestRunProgressPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupSharedTestFixture(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.createClassNameForCommandWindow;
            
            displayedName = createClassNameForCommandWindow(pluginData.Name);
            plugin.printLine(plugin.Catalog.getString('SettingUp', displayedName));
            
            setupSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            description = plugin.Catalog.getString('DoneSettingUp', displayedName);
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.printLine(description);
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end        
        
        function teardownSharedTestFixture(plugin, pluginData)
            import matlab.unittest.internal.diagnostics.createClassNameForCommandWindow;
            
            displayedName = createClassNameForCommandWindow(pluginData.Name);
            plugin.printLine(plugin.Catalog.getString('TearingDown', displayedName));
            
            teardownSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            description = plugin.Catalog.getString('DoneTearingDown', displayedName);
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.printLine(description);
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end
        
        function runTestClass(plugin, pluginData)
            plugin.printLine(plugin.Catalog.getString('Running', pluginData.Name));
            
            runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);

            % Reset the method count now that we are done with this test
            plugin.MethodCount = 0;
            plugin.NeedNewline = false;
            
            plugin.printLine('');
            plugin.printLine(plugin.Catalog.getString('Done', pluginData.Name));
            plugin.printLine(plugin.ContentDelimiter);
            plugin.printLine('');
        end
        
        function setupTestMethod(plugin, pluginData)
            setupTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            if plugin.NeedNewline
                plugin.printEmptyLine();
            end            
        end
        
        function teardownTestMethod(plugin, pluginData)
            teardownTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.print('.');          
            plugin.MethodCount = mod(plugin.MethodCount + 1, length(plugin.ContentDelimiter));
            plugin.NeedNewline = plugin.MethodCount == 0;
        end
    end
end