classdef TestSuiteProgressPlugin < matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin
    % TestSuiteProgressPlugin - Plugin which outputs progress information as text.
    % 
    %   The TestSuiteProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    %
    %   TestSuiteProgressPlugin methods:
    %       TestSuiteProgressPlugin - Class constructor
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TestSuiteProgressPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(TestSuiteProgressPlugin);
    %
    %       % Run the suite to see progress of the test run as text output
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin
    %
    
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    methods
        function plugin = TestSuiteProgressPlugin(varargin)
            %TestSuiteProgressPlugin - Class constructor
            %   PLUGIN = TestSuiteProgressPlugin creates a TestSuiteProgressPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to a
            %   TestRunner instance to show the progress of test runs in text form as
            %   they are run.
            %
            %   PLUGIN = TestSuiteProgressPlugin(STREAM) creates a
            %   TestSuiteProgressPlugin and redirects all the text output produced to
            %   the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   Examples:
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.TestSuiteProgressPlugin;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Create an instance of TestSuiteProgressPlugin
            %       plugin = TestSuiteProgressPlugin;
            %
            %       % Add the plugin to the TestRunner
            %       runner.addPlugin(plugin);
            %
            %       % Run the suite and see progress of the test run as text output
            %       result = runner.run(suite)
            %
            %   See also: OutputStream
            %
            plugin@matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin(varargin{:});
        end
    end
end

% LocalWords:  mypackage testrunprogress
