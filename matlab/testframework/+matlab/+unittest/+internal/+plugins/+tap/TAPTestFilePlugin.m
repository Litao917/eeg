classdef TAPTestFilePlugin < matlab.unittest.plugins.TAPPlugin
    
    properties(Access= private)
        ClassBufferStart
        SuiteBufferStart
        LeadingTests
    end
    
   properties(Constant, GetAccess=private)
       Indentation = '  ';
   end
    
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPTestFilePlugin(varargin)
            plugin@matlab.unittest.plugins.TAPPlugin(varargin{:});
        end
    end
    
    
    methods (Hidden, Access=protected)
        
        function preRunTestSuite(plugin, suite)
            
            plugin.ClassBufferStart = 1;
            plugin.SuiteBufferStart = 1;
            
            plugin.LeadingTests = findLeadingTestsPerClass(suite);
            
            str = sprintf('TAP version 13\n1..%d\n', numel(plugin.LeadingTests));
            yaml.datetime = datestr(now, 30);
            
            plugin.print('%s%s', str, plugin.createYamlBlock(yaml));
            
            
        end
        
        
        
        
        function flushAfterSharedFixture(plugin)
            import matlab.unittest.fixtures.EmptyFixture;
            
            markerFixture = plugin.SharedTestFixtureMarker;
            leadingSuite = plugin.LeadingTests;
            classBufferStart = plugin.ClassBufferStart;
            classBufferEnd = plugin.findBufferEnd(plugin.ClassBufferStart, leadingSuite, markerFixture);
        
            for idx = classBufferStart:classBufferEnd
                suiteBufferStart = plugin.SuiteBufferStart;
                suiteBufferEnd = plugin.findEndOfClass(suiteBufferStart);
                result = plugin.RunTestSuitePluginData.TestResult(suiteBufferStart:suiteBufferEnd);
                plugin.flush(result, datestr(now, 30));
            end
            
        end
        
        function suiteBufferEnd = findEndOfClass(plugin, suiteBufferStart)
            fullSuite = plugin.RunTestSuitePluginData.TestSuite;
            startSuite = fullSuite(suiteBufferStart);
            suiteBufferEnd = suiteBufferStart;
            for idx = suiteBufferStart:numel(fullSuite)
                if ~strcmp(fullSuite(idx).TestParentName, startSuite.TestParentName)
                    suiteBufferEnd = idx - 1;
                    break;
                end
            end
        end
        
        function postRunTestClass(plugin, result)
            if plugin.SharedTestFixtureCount == 0
                plugin.flush(result, datestr(now,30));
            end
        end
        
    end
    
    methods(Access=private)
        
        
        function flush(plugin, result, datetime)
            classBufferStart = plugin.ClassBufferStart;
            
            not = '';
            skip = '';
            if any([result.Failed])
                % Handle failures
                not = 'not ';
            elseif all([result.Incomplete])
                % Handle filtered tests
                skip = ' # SKIP';
            end
            str = sprintf('%sok %d - %s%s\n', ...
                not, classBufferStart, plugin.LeadingTests(classBufferStart).TestParentName, skip);
            
            yaml.datetime = datetime;
            plugin.print('%s', str, plugin.createYamlBlock(yaml));
            plugin.SuiteBufferStart = plugin.SuiteBufferStart + numel(result);
            plugin.ClassBufferStart = classBufferStart + 1;
        end
        
        
        
        function str = createYamlBlock(plugin, yaml)
            import matlab.unittest.internal.diagnostics.indent;
            str = sprintf('---\n');
            fields = fieldnames(yaml);
            for idx = 1:numel(fields)
                str = sprintf('%s%s%s: %s\n', str, plugin.Indentation, ...
                    fields{idx}, yaml.(fields{idx}));
            end
            
            str = sprintf('%s...', str);
            str = indent(str, plugin.Indentation);
            str = sprintf('%s\n', str);
        end
     
        
        
    end
    
end

function leadingTests = findLeadingTestsPerClass(suite)
if isempty(suite)
    leadingTests = matlab.unittest.Test.empty;
    return
end
testNames = {suite.TestParentName}';
previousTestNames = [{NaN}; testNames(1:end-1)];
collapsedTestNamesIndex = ~strcmp(testNames, previousTestNames);
leadingTests = suite(collapsedTestNamesIndex);
end

% LocalWords:  mypackage
