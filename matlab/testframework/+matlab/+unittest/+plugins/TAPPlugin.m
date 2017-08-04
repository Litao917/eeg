classdef TAPPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
        matlab.unittest.internal.plugins.Printable
    %TAPPlugin - Plugin that produces a TAP Stream
    %   The TAPPlugin allows one to configure a TestRunner to produce output
    %   conforming to the Test Anything Protocol (TAP). When the test output is
    %   produced using this format, MATLAB Unit Test results can be integrated
    %   into other third party systems that recognize the TAP protocol. For
    %   example, using this plugin MATLAB tests can be integrated into
    %   continuous integration systems like <a href="http://jenkins-ci.org/">Jenkins</a>TM or <a href="http://www.jetbrains.com/teamcity">TeamCity</a>(R).
    %
    %   TAPPlugin Methods:
    %       producingOriginalFormat - Construct a plugin that produces the original TAP format.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TAPPlugin;
    %       import matlab.unittest.plugins.ToFile;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add a TAPPlugin to the TestRunner
    %       tapFile = 'MyTAPOutput.tap';
    %       plugin = TAPPlugin.producingOriginalFormat(ToFile(tapFile));
    %       runner.addPlugin(plugin);
    %
    %       result = runner.run(suite);
    %
    %       disp(fileread(tapFile));
    %
    %   See also: TestRunnerPlugin, ToFile
     
	% Copyright 2013 The MathWorks, Inc.
        
    properties(Hidden, SetAccess=private, GetAccess=protected)
        RunTestSuitePluginData;
        SharedTestFixtureCount
        SharedTestFixtureMarker = matlab.unittest.fixtures.EmptyFixture.empty;
    end
    
    properties(Dependent, Hidden, GetAccess=protected)
        HasSharedTestFixture
    end
        
    methods(Static)
        function plugin = producingOriginalFormat(varargin)
            % producingOriginalFormat - Construct a plugin that produces the original TAP format.
            %   
            %   PLUGIN = TAPPlugin.producingOriginalFormat() returns a plugin that
            %   produces text output in the form of the original Test Anything Protocol
            %   format (version 12). This output is printed to the MATLAB Command
            %   Window. Any other output also produced to the Command Window can
            %   invalidate the TAP stream. This can be avoided by sending the TAP
            %   output to another OutputStream as shown below.
            %
            %   PLUGIN = TAPPlugin.producingOriginalFormat(STREAM) creates a TAPPlugin
            %   and redirects all the text output produced to the OutputStream STREAM.
            %   If this is not supplied, a ToStandardOutput stream is used.
            %
            %   Examples:
            %       import matlab.unittest.plugins.TAPPlugin;
            %       import matlab.unittest.plugins.ToFile;
            %
            %       % Create a TAP plugin that sends TAP Output to the MATLAB Command
            %       % Window
            %       plugin = TAPPlugin.producingOriginalFormat;
            %
            %       % Create a TAP plugin that sends TAP Output to a file
            %       plugin = TAPPlugin.producingOriginalFormat(ToFile('MyTAPStream.tap'));
            %
            %   See also: OutputStream, ToFile
            
            plugin = matlab.unittest.plugins.tap.TAPOriginalFormatPlugin(varargin{:});
        end
    end
    methods(Hidden, Static)
        function plugin = producingVersion13(varargin)
            
            import matlab.unittest.plugins.ToStandardOutput;
            p = inputParser;
            p.addOptional('OutputStream', ToStandardOutput, ...
                @(v) isscalar(v) && isa(v, 'matlab.unittest.plugins.OutputStream'));
             % The option below is unsupported and will change in a future release;
            p.addParameter('GroupedByFile', false, @(v) islogical(v) && isscalar(v));
            p.parse(varargin{:});
            
            if ~p.Results.GroupedByFile
                plugin = matlab.unittest.plugins.tap.TAPVersion13Plugin(p.Results.OutputStream);
            else
                plugin = matlab.unittest.internal.plugins.tap.TAPTestFilePlugin(p.Results.OutputStream);
            end
        end
    end
    
    methods(Hidden, Abstract, Access=protected)
        preRunTestSuite(plugin, suite);
        flushAfterSharedFixture(plugin);
        postRunTestClass(plugin, result);
    end
        
    
    
    methods(Access=protected)
        function plugin = TAPPlugin(varargin)
            plugin@matlab.unittest.internal.plugins.Printable(varargin{:});
        end
    end
    
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.fixtures.EmptyFixture;
            
            plugin.SharedTestFixtureMarker = EmptyFixture.empty;
            plugin.SharedTestFixtureCount = 0;
            plugin.RunTestSuitePluginData = pluginData;
            
            plugin.preRunTestSuite(pluginData.TestSuite);
            plugin.runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            if isempty(plugin.SharedTestFixtureMarker)
                plugin.SharedTestFixtureMarker = fixture;
            end
            name = pluginData.Name;
            fixture.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, name));
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            name = pluginData.Name;            
            testCase.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, name));
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            name = pluginData.Name;
            testCase.addlistener('FatalAssertionFailed', @(obj, evd) plugin.bailOut(obj, evd, name));
        end
        
        function setupSharedTestFixture(plugin, pluginData)
            setupSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.SharedTestFixtureCount = plugin.SharedTestFixtureCount + 1;
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            import matlab.unittest.fixtures.EmptyFixture;
            
            teardownSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.SharedTestFixtureCount = plugin.SharedTestFixtureCount - 1;
            
            
            if plugin.SharedTestFixtureCount == 0
                plugin.flushAfterSharedFixture();
                plugin.SharedTestFixtureMarker = EmptyFixture.empty;
            end

        end
        
        function runTestClass(plugin, pluginData)
            runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.postRunTestClass(pluginData.TestResult);
        end
        
        
    end
    
    methods(Hidden, Access= protected)
        
        function bufferEnd = findBufferEnd(~, bufferStart, suite, endMarker)
            bufferEnd = numel(suite);
            for idx = bufferStart:bufferEnd
                if ~suite(idx).SharedTestFixtures.containsEquivalentFixture(endMarker)
                    bufferEnd = idx - 1;
                    break;
                end
            end
        end
    end
    
    methods(Access=private)


        function bailOut(plugin, ~, evd, name)
            
            str = sprintf('Bail out! %s', name);
            
            userDiag = evd.TestDiagnosticResult;
            
            
            for idx = 1:numel(userDiag)
                reason = userDiag{idx};
                if ~isempty(reason)
                    reason = regexprep(reason, '\n.*', '');
                    str = sprintf('%s: %s', str, reason);
                    break;
                end
            end
            plugin.printLine(str);
        end
            

    end
    methods
        function tf = get.HasSharedTestFixture(plugin)
            tf = plugin.SharedTestFixtureCount > 0;
        end
    end
end

% LocalWords:  mypackage jenkins ci jetbrains teamcity evd
