classdef TAPOriginalFormatPlugin < matlab.unittest.plugins.TAPPlugin
    %
    
    % This class is undocumented and will change in a future release.
    
    % Copyright 2013 The MathWorks, Inc.
    properties(Access= private)
        HasClassFixture
        BufferStart
    end
    
    properties(Access=private, Dependent)
        FlushAtTest
        FlushAtClass
    end
        

    
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPOriginalFormatPlugin(varargin)
            plugin@matlab.unittest.plugins.TAPPlugin(varargin{:});
        end
    end
    
    
    methods (Access=protected)
        
        function preRunTestSuite(plugin, suite)
            plugin.BufferStart = 1;
            plugin.print('1..%d\n', numel(suite));
        end
        
       
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            cls = metaclass(testCase);
            
            setupMethods = cls.MethodList.findobj('TestClassSetup',true);
            teardownMethods = cls.MethodList.findobj('TestClassTeardown',true);
            plugin.HasClassFixture = ~isempty(setupMethods) || ~isempty(teardownMethods);
            
        end
        
        function flushAfterSharedFixture(plugin)  
            
            bufferEnd = plugin.findBufferEnd(plugin.BufferStart, ...
                plugin.RunTestSuitePluginData.TestSuite, plugin.SharedTestFixtureMarker);
            result = plugin.RunTestSuitePluginData.TestResult(plugin.BufferStart:bufferEnd);
            plugin.flush(result);
        end
        
        function postRunTestClass(plugin, result)
            if plugin.FlushAtClass
                plugin.flush(result);
            end
        end
        function runTest(plugin, pluginData)
            
            runTest@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            if plugin.FlushAtTest
                plugin.flush(pluginData.TestResult);               
            end
            
        end

        
    end
    
    methods(Access=private)


        function flush(plugin, result)
            bufferStart = plugin.BufferStart;
            str = '';
            for idx = 1:numel(result)
                thisResult = result(idx);
               
                not = '';
                skip = '';
                if thisResult.Failed
                    % Handle failure
                    not = 'not ';
                elseif thisResult.Incomplete
                    % Handle filtered tests
                    skip = ' # SKIP ';
                end
                str = sprintf('%s%sok %d - %s%s\n', str, ...
                    not, bufferStart, thisResult.Name, skip);
                
                bufferStart = bufferStart + 1;
            end
            plugin.print('%s', str);
            plugin.BufferStart = bufferStart;
        end
        

            
    end
    methods

        function tf = get.FlushAtTest(plugin)
            

            if plugin.HasSharedTestFixture
                tf = false;
                return 
            end
            
            if plugin.HasClassFixture
                tf = false;
                return 
            end
            
            tf = true;
        end

        function tf = get.FlushAtClass(plugin)
            if plugin.HasSharedTestFixture
                tf = false;
                return 
            end
            
            if ~plugin.HasClassFixture
                tf = false;
                return 
            end
            tf = true;
        end
    end
end
