classdef TestRunnerPlugin < matlab.unittest.internal.TestContentOperator
    % TestRunnerPlugin - Plugin interface for extending the TestRunner
    %
    %   The TestRunnerPlugin interface allows for extension of the
    %   matlab.unittest.TestRunner. In order to customize the test run, a
    %   subclass can be created that has the opportunity to override methods
    %   that are important when operating on test content. A default
    %   implementation is provided for each method that can be overridden, so
    %   not all methods must be implemented in every subclass. Only the methods
    %   of interest should be overridden. It is, however, the responsibility of
    %   every method implemented by the subclass to invoke the superclass
    %   method passing the plugin data as received. 
    %
    %   To run tests with this extension, add the custom
    %   TestRunnerPlugin to the TestRunner being used for running the
    %   tests. The following methods are available for extension.
    %
    %   TestRunnerPlugin methods:
    %       runTestSuite              - Extend running the TestSuite handed to TestRunner
    %       createSharedTestFixture   - Extend creating a shared test fixture instance
    %       setupSharedTestFixture    - Extend setting up a shared test fixture
    %       runTestClass              - Extend running tests from the same test class
    %       createTestClassInstance   - Extend creating a class level TestCase instance
    %       setupTestClass            - Extend setting up test class
    %       runTest                   - Extend running a TestSuite element
    %       createTestMethodInstance  - Extend creating a method level TestCase instance
    %       setupTestMethod           - Extend setting up test method
    %       runTestMethod             - Extend running a Test method
    %       teardownTestMethod        - Extend tearing down test method
    %       teardownTestClass         - Extend tearing down test class
    %       teardownSharedTestFixture - Extend tearing down a shared test fixture
    %
    %   TestRunner passes information pertinent to each plugin method being
    %   evaluated in the form of plugin data. The table below shows the class
    %   of PluginData that each method receives for introspection. 
    %
    %    ------------------------------------------------------------------
    %   |         Method Name             |        PluginData Class        |
    %    ------------------------------------------------------------------
    %   |   runTestSuite                  |  TestSuiteRunPluginData        |
    %   |   createSharedTestFixture       |  PluginData                    |
    %   |   setupSharedTestFixture        |  SharedTestFixturePluginData   |
    %   |   runTestClass                  |  TestSuiteRunPluginData        |
    %   |   createTestClassInstance       |  PluginData                    |
    %   |   setupTestClass                |  PluginData                    |
    %   |   runTest                       |  TestSuiteRunPluginData        |
    %   |   createTestMethodInstance      |  PluginData                    |
    %   |   setupTestMethod               |  PluginData                    |
    %   |   runTestMethod                 |  TestSuiteRunPluginData        |
    %   |   teardownTestMethod            |  PluginData                    |
    %   |   teardownTestClass             |  PluginData                    |
    %   |   teardownSharedTestFixture     |  SharedTestFixturePluginData   |
    %    ------------------------------------------------------------------
    %
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %   Example: Authoring a custom TestRunnerPlugin
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %   
    %   AssertionCountingPlugin is a sample plugin that counts the number
    %   of assertions (passing and failing) when running a specified test
    %   suite and prints a brief summary at the end.
    %   
    %   classdef AssertionCountingPlugin < matlab.unittest.plugins.TestRunnerPlugin
    %       
    %       properties
    %           NumPassingAssertions = 0;
    %           NumFailingAssertions = 0;
    %       end
    %     
    %       methods (Access = protected)
    %           function runTestSuite(plugin, pluginData) 
    %               suiteSize = numel(pluginData.TestSuite);
    %               fprintf('## Running a total of %d tests\n', suiteSize);
    %             
    %               % Reset the assertion counts
    %               plugin.NumPassingAssertions = 0;
    %               plugin.NumFailingAssertions = 0;
    %   
    %               % Invoke super class method to run the test suite
    %               runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
    %             
    %               fprintf('## Done running tests\n');
    %               plugin.printAssertionSummary();
    %           end
    %         
    %           function fixture = createSharedTestFixture(plugin, pluginData)
    %               % Invoke super class method to create shared test fixture instance
    %               fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
    %             
    %               % Listen to passing and failing assertions on fixture 
    %               fixture.addlistener('AssertionPassed', @(~,~)plugin.incrementPassingAssertionsCount);
    %               fixture.addlistener('AssertionFailed', @(~,~)plugin.incrementFailingAssertionsCount);
    %           end
    %         
    %           function testCase = createTestClassInstance(plugin, pluginData)
    %               % Invoke super class method to create class level TestCase instance            
    %               testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
    %             
    %               % Listen to passing and failing assertions on class level TestCase
    %               testCase.addlistener('AssertionPassed', @(~,~)plugin.incrementPassingAssertionsCount);
    %               testCase.addlistener('AssertionFailed', @(~,~)plugin.incrementFailingAssertionsCount);
    %           end
    %         
    %           function testCase = createTestMethodInstance(plugin, pluginData)
    %               % Invoke super class method to create method level TestCase instance            
    %               testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
    %             
    %               % Listen to passing and failing assertions on method level TestCase
    %               testCase.addlistener('AssertionPassed', @(~,~)plugin.incrementPassingAssertionsCount);
    %               testCase.addlistener('AssertionFailed', @(~,~)plugin.incrementFailingAssertionsCount);
    %           end
    %         
    %           function runTest(plugin, pluginData)
    %               % Display test name when it is being run
    %               fprintf('### Running test: %s\n', pluginData.Name);            
    %             
    %               % Invoke super class method to run the test
    %               runTest@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
    %           end
    %         
    %       end
    %     
    %       methods (Access = private)
    %           function incrementPassingAssertionsCount(plugin)
    %               % Counter counting passing assertions 
    %               plugin.NumPassingAssertions = plugin.NumPassingAssertions + 1;
    %           end
    %         
    %           function incrementFailingAssertionsCount(plugin)
    %               % Counter counting failing assertions 
    %               plugin.NumFailingAssertions = plugin.NumFailingAssertions + 1;
    %           end
    %         
    %           function printAssertionSummary(plugin)
    %               % Print the assertion count summary
    %               fprintf('%s\n', repmat('_', 1, 30));
    %               fprintf('Total Assertions: %d\n', plugin.NumPassingAssertions + plugin.NumFailingAssertions);
    %               fprintf('\t%d Passed, %d Failed\n', plugin.NumPassingAssertions, plugin.NumFailingAssertions);
    %           end
    %       end
    %   end  
    %
    %   
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Example: Extending TestRunner with a custom TestRunnerPlugin
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.TestRunner;
    %
    %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
    %       runner = TestRunner.withNoPlugins;
    %       runner.addPlugin(AssertionCountingPlugin)
    %
    %       result = runner.run(suite)
    %
    %   See also: matlab.unittest.TestRunner
    %             matlab.unittest.plugins.plugindata.PluginData
    %             matlab.unittest.plugins.plugindata.TestSuiteRunPluginData
    %             matlab.unittest.plugins.plugindata.SharedTestFixturePluginData

    
    %       evaluateMethod (Hidden method)
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    properties (SetAccess=?matlab.unittest.TestRunner, GetAccess=private)
        NextRunTestSuitePlugin              = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextRunTestClassPlugin              = matlab.unittest.plugins.TestRunnerPlugin.empty;        
        NextRunTestPlugin                   = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextRunTestMethodPlugin             = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextCreateSharedTestFixturePlugin   = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextCreateTestClassInstancePlugin   = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextCreateTestMethodInstancePlugin  = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextSetupSharedTestFixturePlugin    = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextTeardownSharedTestFixturePlugin = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextSetupTestClassPlugin            = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextTeardownTestClassPlugin         = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextSetupTestMethodPlugin           = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextTeardownTestMethodPlugin        = matlab.unittest.plugins.TestRunnerPlugin.empty;
        NextEvaluateMethodPlugin            = matlab.unittest.plugins.TestRunnerPlugin.empty;
    end
    
    methods (Hidden, Access=protected)
        function plugin = TestRunnerPlugin
        end
    end
    
    methods (Access=protected)        
        function runTestSuite(plugin, pluginData)
            % RUNTESTSUITE - Extend running the TestSuite handed to TestRunner
            %
            %   RUNTESTSUITE(PLUGIN, PLUGINDATA) plugin method must be overridden in
            %   order to extend running the original TestSuite array handed to the
            %   TestRunner. The PLUGINDATA holds information about the test suite being
            %   run that can be used to introspect into the test content being
            %   executed.
            %
            %   Example:
            %
            %   classdef ExamplePlugin < matlab.unittest.plugins.TestRunnerPlugin
            %       
            %       methods (Access = protected)
            %           function runTestSuite(plugin, pluginData)   
            %             
            %               % Introspect into pluginData to get TestSuite size
            %               suiteSize = numel(pluginData.TestSuite);            
            %               fprintf('### Running a total of %d tests\n', suiteSize);
            %             
            %               % Invoke the super class method
            %               runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData)            
            %           end
            %       end
            %     
            %   end
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.TestSuiteRunPluginData
            %             matlab.unittest.TestResult            
            plugin.NextRunTestSuitePlugin.runTestSuite(pluginData);
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            % CREATESHAREDTESTFIXTURE - Extend creating a shared test fixture instance
            %
            %   CREATESHAREDTESTFIXTURE(PLUGIN, PLUGINDATA) plugin method must be
            %   overridden in order to extend creating instances of shared test
            %   fixtures. The TestRunner evaluates this plugin method for each shared
            %   test fixture that needs to be setup during the test run. The PLUGINDATA
            %   holds information about the shared test fixture being created. The
            %   fixture instance created can then be used to customize the test run.
            %   This method is evaluated within the scope of RUNTESTSUITE.
            %   
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   Example: 'ExamplePlugin' listening to fixture assertion failures
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   
            %   classdef ExamplePlugin < matlab.unittest.plugins.TestRunnerPlugin
            %     
            %       properties (SetAccess = private)
            %           % FixtureAssertionFailureData - Accumulate fixture assertion failure data
            %           %
            %           %   This property accumulates fixture assertion failure data across
            %           %   multiple test runs performed within the lifetime of the
            %           %   plugin. 
            %           FixtureAssertionFailureData = {};
            %       end
            %     
            %       methods (Access = protected)
            %           function fixture = createSharedTestFixture(plugin, pluginData)
            %               % Invoke the super class method
            %               fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            %             
            %               % Get the fixture name
            %               fixtureName = pluginData.Name;
            %             
            %               % Add a listener to fixture assertion failures
            %               % and capture the qualification failure information
            %               fixture.addlistener('AssertionFailed', @(~,evd) plugin.captureFixtureAssertionFailureData(evd, fixtureName));
            %           end
            %       end
            %     
            %       methods (Access = private)
            %           function captureFixtureAssertionFailureData(plugin, eventData, fixtureName)
            %               plugin.FixtureAssertionFailureData{end+1} = struct(...
            %                   'FixtureName', fixtureName, ...
            %                   'ActualValue', eventData.ActualValue, ...
            %                   'Constraint' , eventData.Constraint, ...
            %                   'Stack'      , eventData.Stack);
            %           end
            %       end
            %     
            %   end
            %
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            %   % Using the ExamplePlugin
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            %   
            %   import matlab.unittest.TestSuite;
            %   import matlab.unittest.TestRunner;
            %
            %   % Create suite1            
            %   suite1 = TestSuite.fromClass(?mypackage.MyTestClass1);
            %
            %   runner = TestRunner.withNoPlugins;
            %   plugin = ExamplePlugin;
            %   runner.addPlugin(plugin);
            %   
            %   % Captures fixture assertion failure data from running 'suite1'
            %   result = runner.run(suite1)
            % 
            %   % Create suite2
            %   suite2 = TestSuite.fromClass(?mypackage.MyTestClass2);
            % 
            %   % Continues to capture fixture assertion failure data from
            %   % running 'suite2'
            %   result = runner.run(suite2)
            %
            % 
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData
            fixture = plugin.NextCreateSharedTestFixturePlugin.createSharedTestFixture(pluginData);
        end
        
        function setupSharedTestFixture(plugin, pluginData)
            % SETUPSHAREDTESTFIXTURE - Extend setting up a shared test fixture
            % 
            %   SETUPSHAREDTESTFIXTURE(PLUGIN, PLUGINDATA) plugin method must be
            %   overridden to extend setting up a shared text fixture. The
            %   TestRunner evaluates this plugin method for each shared test fixture
            %   that needs to be setup during the test run. The PLUGINDATA holds
            %   information about the shared test fixture being setup. This
            %   method is evaluated within the scope of RUNTESTSUITE.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.SharedTestFixturePluginData
            %             matlab.unittest.plugins.TestRunnerPlugin/createSharedTestFixture
            plugin.NextSetupSharedTestFixturePlugin.setupSharedTestFixture(pluginData);
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            % TEARDOWNSHAREDTESTFIXTURE - Extend tearing down a shared test fixture
            % 
            %   TEARDOWNSHAREDTESTFIXTURE(PLUGIN, PLUGINDATA) plugin method must be
            %   overridden to extend tearing down a shared text fixture. The
            %   TestRunner evaluates this plugin method for each shared test fixture
            %   that needs to be torn down during the test run. The PLUGINDATA holds
            %   information about the shared test fixture being torn down. This method
            %   is evaluated within the scope of RUNTESTSUITE.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.SharedTestFixturePluginData
            %             matlab.unittest.plugins.TestRunnerPlugin/createSharedTestFixture
            plugin.NextTeardownSharedTestFixturePlugin.teardownSharedTestFixture(pluginData);
        end
        
        function runTestClass(plugin, pluginData)
            % RUNTESTCLASS - Extend running tests from the same test class
            %
            %   RUNTESTCLASS(PLUGIN, PLUGINDATA) plugin method must be overridden in
            %   order to extend running tests that belong to the same test class. This
            %   suite is calculated from the original TestSuite array handed to the
            %   TestRunner. The PLUGINDATA holds information about the test suite being
            %   run, which can be used to introspect into the test content being
            %   executed. TestRunner will invoke this method only if the required
            %   shared test fixtures are setup completely.
            %
            %   Example:
            %
            %   classdef ExamplePlugin < matlab.unittest.plugins.TestRunnerPlugin
            %       
            %       methods (Access = protected)
            %           function runTestClass(plugin, pluginData)   
            %             
            %               % Introspect into pluginData to get TestSuite size
            %               suiteSize = numel(pluginData.TestSuite);            
            %               fprintf('### Running %d tests from %s\n', suiteSize, pluginData.Name);
            %             
            %               % Invoke the super class method
            %               runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData)            
            %           end
            %       end
            %     
            %   end
            %            
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.TestSuiteRunPluginData
            %             matlab.unittest.TestResult                        
            plugin.NextRunTestClassPlugin.runTestClass(pluginData);
        end
        
        function testcase = createTestClassInstance(plugin, pluginData)
            % CREATETESTCLASSINSTANCE - Extend creating a class level TestCase instance
            %
            %   CREATETESTCLASSINSTANCE(PLUGIN, PLUGINDATA) plugin method must be
            %   overridden to extend creating a class level TestCase instance. The
            %   TestCase instance created can then be used to customize running tests
            %   that belong to the same test class. The PLUGINDATA holds information
            %   about the test class instance being created. This method is evaluated
            %   from within the scope of RUNTESTCLASS. This TestCase
            %   instance is received by test class methods with attributes
            %   TestClassSetup and TestClassTeardown.
            %
            %   Example: 'ExamplePlugin' listening to class level assumption failures
            %   
            %   classdef ExamplePlugin < matlab.unittest.plugins.TestRunnerPlugin
            %     
            %       properties (SetAccess = private)
            %           % TestClassAssumptionFailureData - Accumulate class level assumption failure data
            %           %
            %           %   This property accumulates assumption failure data from test
            %           %   class setup/teardown across multiple test suite runs performed
            %           %   within the lifetime of the plugin.
            %           TestClassAssumptionFailureData = {};
            %       end
            %     
            %       methods (Access = protected)
            %           function testCase = createTestClassInstance(plugin, pluginData)
            %               % Invoke super class method
            %               testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            %             
            %               % Get the test class name
            %               className = pluginData.Name;
            %             
            %               % Add a listener to capture assumption failures
            %               testCase.addlistener('AssumptionFailed', @(~,evd) plugin.captureClassLevelAssumptionFailureData(evd, className));
            %           end
            %       end
            %             
            %       methods (Access = private)
            %           function captureClassLevelAssumptionFailureData(plugin, eventData, className)
            %               plugin.TestClassAssumptionFailureData{end+1} = struct(...
            %                   'TestClassName', className, ...
            %                   'ActualValue'  , eventData.ActualValue, ...
            %                   'Constraint'   , eventData.Constraint, ...
            %                   'Stack'        , eventData.Stack);
            %           end
            %       end
            %     
            %   end
            %
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            %   % Using the ExamplePlugin
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            %   
            %   import matlab.unittest.TestSuite;
            %   import matlab.unittest.TestRunner;
            %
            %   % Create suite1            
            %   suite1 = TestSuite.fromClass(?mypackage.MyTestClass1);
            %
            %   runner = TestRunner.withNoPlugins;
            %   plugin = ExamplePlugin;
            %   runner.addPlugin(plugin);
            %   
            %   % Captures class level assumption failure data from running 'suite1'
            %   result = runner.run(suite1)
            % 
            %   % Create suite2
            %   suite2 = TestSuite.fromClass(?mypackage.MyTestClass2);
            % 
            %   % Continues to capture class level assumption failure data from
            %   % running 'suite2'
            %   result = runner.run(suite2)
            %
            %             
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData            
            testcase = plugin.NextCreateTestClassInstancePlugin.createTestClassInstance(pluginData);
        end
        
        function setupTestClass(plugin, pluginData)
            % SETUPTESTCLASS - Extend setting up Test Class
            % 
            %   SETUPTESTCLASS(PLUGIN, PLUGINDATA) plugin method must be overridden to
            %   extend setting up a test class. The TestRunner evaluates this method
            %   to perform test class setup for all tests run from within the scope of
            %   RUNTESTCLASS. The PLUGINDATA hold information about the test class
            %   being setup. This method may be evaluated multiple times if
            %   class setup parameterization is involved. In which case, it
            %   will be invoked as many times as there are class setup
            %   parameters.
            %            
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData   
            %             matlab.unittest.plugins.TestRunnerPlugin/createTestClassInstance
            plugin.NextSetupTestClassPlugin.setupTestClass(pluginData);
        end
        
        function teardownTestClass(plugin, pluginData)
            % TEARDOWNTESTCLASS - Extend tearing down Test Class
            % 
            %   TEARDOWNTESTCLASS(PLUGIN, PLUGINDATA) plugin method must be overridden
            %   to extend tearing down a test class. The TestRunner evaluates this
            %   method to perform test class teardown for all tests run from
            %   within the scope of RUNTESTCLASS. The PLUGINDATA hold information about
            %   the test class being torn down.
            %            
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData            
            %             matlab.unittest.plugins.TestRunnerPlugin/createTestClassInstance
            plugin.NextTeardownTestClassPlugin.teardownTestClass(pluginData);
        end
        
        function runTest(plugin, pluginData)
            % RUNTEST - Extend running a TestSuite element
            %
            %   RUNTEST(PLUGIN, PLUGINDATA) plugin method must be overridden in order
            %   to extend running a scalar test element in the TestSuite array
            %   handed to the TestRunner. The PLUGINDATA holds information about the
            %   test element being run, which can be used to introspect into the test
            %   content being executed. TestRunner will invoke this method
            %   only if the required shared test fixtures' setup and class
            %   level setup are complete.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.TestSuiteRunPluginData
            %             matlab.unittest.TestResult      
            %             matlab.unittest.plugins.TestRunnerPlugin/runTestClass
            plugin.NextRunTestPlugin.runTest(pluginData);
        end
        
        function testcase = createTestMethodInstance(plugin, pluginData)
            % CREATETESTMETHODINSTANCE - Extend creating a method level TestCase instance
            %
            %   CREATETESTMETHODINSTANCE(PLUGIN, PLUGINDATA) plugin method must be
            %   overridden to extend creating a test method level TestCase instance.
            %   The TestRunner evaluates this method from with the scope of RUNTEST.
            %   The TestCase instance created can be used to customize the test suite
            %   element run. The PLUGINDATA holds information about the method level
            %   TestCase instance being created. This TestCase
            %   instance is received by test class methods with attributes
            %   TestMethodSetup and TestMethodTeardown.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData     
            %             matlab.unittest.plugins.TestRunnerPlugin/createTestClassInstance
            testcase = plugin.NextCreateTestMethodInstancePlugin.createTestMethodInstance(pluginData);
        end

        function setupTestMethod(plugin, pluginData)
            % SETUPTESTMETHOD - Extend setting up Test Method
            % 
            %   SETUPTESTMETHOD(PLUGIN, PLUGINDATA) plugin method must be overridden to
            %   extend setting up a test method. The TestRunner evaluates this
            %   method to perform test method setup for the single test suite element
            %   run from within the scope of RUNTEST. The PLUGINDATA holds information
            %   about the test method being setup.
            %
            %
            %   Example: 'ExamplePlugin' displaying setup context
            %
            %   classdef ExamplePlugin < matlab.unittest.plugins.TestRunnerPlugin
            %       
            %       methods (Access = protected)
            %           function setupTestMethod(plugin, pluginData)
            %               fprintf('### Setting up: %s\n', pluginData.Name);
            %               setupTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            %           end
            %       end
            %     
            %   end       
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData                                    
            plugin.NextSetupTestMethodPlugin.setupTestMethod(pluginData);
        end
        
        function teardownTestMethod(plugin, pluginData)
            % TEARDOWNTESTMETHOD - Extend setting up Test Method
            % 
            %   TEARDOWNTESTMETHOD(PLUGIN, PLUGINDATA) plugin method must be overridden
            %   to extend tearing down a test method. The TestRunner evaluates this
            %   method to perform test method teardown for the single test suite
            %   element run from within the scope of RUNTEST. The PLUGINDATA holds
            %   information about the test method being torn down.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.PluginData    
            %             matlab.unittest.plugins.TestRunnerPlugin/setupTestMethod
            plugin.NextTeardownTestMethodPlugin.teardownTestMethod(pluginData);
        end
        
        function runTestMethod(plugin, pluginData)
            % RUNTESTMETHOD - Extend running a Test method
            %
            %   RUNTESTMETHOD(PLUGIN, PLUGINDATA) plugin method must be overridden in
            %   order to extend running a Test method. This method is evaluated from
            %   within the scope of RUNTEST between setting up and tearing down the
            %   scalar TestSuite element. The PLUGINDATA holds information about the
            %   Test method being run, which can be used to introspect into the test
            %   content being executed.
            %
            %   See also: matlab.unittest.TestRunner
            %             matlab.unittest.plugins.plugindata.TestSuiteRunPluginData
            %             matlab.unittest.TestResult   
            %             matlab.unittest.plugins.TestRunnerPlugin/runTest
            %             matlab.unittest.plugins.TestRunnerPlugin/runTestClass
            plugin.NextRunTestMethodPlugin.runTestMethod(pluginData)
        end
    end
       
    methods (Hidden, Access=protected)
        function evaluateMethod(plugin, method, content, arguments)
            plugin.NextEvaluateMethodPlugin.evaluateMethod(method, content, arguments)
        end        
    end 
end
% LocalWords:  mypackage plugindata RUNTESTSUITE CREATESHAREDTESTFIXTURE evd
% LocalWords:  SETUPSHAREDTESTFIXTURE TEARDOWNSHAREDTESTFIXTURE RUNTESTCLASS
% LocalWords:  CREATETESTCLASSINSTANCE SETUPTESTCLASS TEARDOWNTESTCLASS RUNTEST
% LocalWords:  CREATETESTMETHODINSTANCE SETUPTESTMETHOD TEARDOWNTESTMETHOD
% LocalWords:  RUNTESTMETHOD
