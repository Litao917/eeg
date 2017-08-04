classdef(Sealed) TestRunner < matlab.unittest.internal.TestContentOperator
    % TestRunner - Class used to run tests in matlab.unittest
    % 
    %   The matlab.unittest.TestRunner class is the fundamental API used to run
    %   a suite of tests in matlab.unittest. It runs and operates on TestSuite
    %   arrays and is responsible for constructing the TestCase class instances
    %   containing test code, setting up and tearing down fixtures, and
    %   executing the test methods. It ensures that all of the test and fixture
    %   methods are run at the appropriate times and in the appropriate manner,
    %   and records information about the run into TestResults. It is the only
    %   supported class with the ability to run Test content to ensure that
    %   tests are run in the manner guaranteed by the TestCase interface.
    %
    %   To create a TestRunner for use in running tests, one can use one of the
    %   static methods provided by the TestRunner class.
    %    
    %   TestRunner methods:
    %       withNoPlugins  - Create the simplest runner possible
    %       withTextOutput - Create a runner for command window output
    %
    %       run       - Run all the tests in a TestSuite array
    %       addPlugin - Add a TestRunnerPlugin to a TestRunner
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %
    %       % Create a "standard" TestRunner and run the suite
    %       runner = TestRunner.withTextOutput;
    %       runner.run(suite)
    %
    %   See also: TestSuite, TestResult, plugins.TestRunnerPlugin
    %     
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    
    properties(Access = private)
        TestRunData;
        ApplyFailureFunction;
          
        ActiveSharedFixtureStruct = struct(...
            'Instance', {}, ...
            'UserDefined', {}, ...
            'StartIndex', {});
        ClassLevelStruct = struct(...
            'TestCase', [], ...
            'SetupMethods', [], ...
            'TeardownMethods', []);
        
        CurrentMethodLevelTestCase;
        RequiredSharedTestFixtureToSetup = matlab.unittest.fixtures.EmptyFixture.empty;
        
        % Plugin Data 
        RunTestSuitePluginData               = matlab.unittest.plugins.plugindata.TestSuiteRunPluginData.empty;
        RunTestClassPluginData               = matlab.unittest.plugins.plugindata.TestSuiteRunPluginData.empty;
        RunSharedTestCasePluginData          = matlab.unittest.plugins.plugindata.TestSuiteRunPluginData.empty;
        RunTestPluginData                    = matlab.unittest.plugins.plugindata.TestSuiteRunPluginData.empty;
        RunTestMethodPluginData              = matlab.unittest.plugins.plugindata.TestSuiteRunPluginData.empty;
        SharedTestFixtureCreationPluginData  = matlab.unittest.plugins.plugindata.PluginData.empty;
        SetupSharedTestFixturePluginData     = matlab.unittest.plugins.plugindata.SharedTestFixturePluginData.empty;
        TeardownSharedTestFixturePluginData  = matlab.unittest.plugins.plugindata.SharedTestFixturePluginData.empty;
        TestClassPluginData                  = matlab.unittest.plugins.plugindata.PluginData.empty;
        TestMethodPluginData                 = matlab.unittest.plugins.plugindata.PluginData.empty;
        
        HasExecutedFullPluginStack = false;
        
        % Plugin Hierarchy Management
        PluginList = matlab.unittest.plugins.TestRunnerPlugin.empty; % used for save/load for backwards compatibility
        PluginHeadMap;  % Mapping between plugin method names and smart plugin heads
    end
    
    properties(Dependent, Access=private)
        ActiveSharedFixtureInstances
        ActiveUserDefinedSharedFixtureInstances
        
        CurrentIndex;
        CurrentResult;
        CurrentSuite;
    end
    
    properties (Constant, Access = private)
        PluginMethodNames         = getPluginMethodNames();
        NextPluginPropertyNameMap = createNextPluginPropertyNameMap();
        
        WithTextOutputParser      = createWithTextOutputParser;
    end
    
    methods(Static)
        function runner = withNoPlugins
            % withNoPlugins  - Create the simplest runner possible
            %
            %   RUNNER = matlab.unittest.TestRunner.withNoPlugins creates a TestRunner
            %   that is guaranteed to have no plugins installed and returns it in
            %   RUNNER. It is the method one can use to create the simplest runner
            %   possible without violating the guarantees a test writer has when
            %   writing TestCase classes. This runner is a silent runner, meaning that
            %   regardless of passing or failing tests, this runner produces no output
            %   whatsoever, although the results returned after running a test suite
            %   are accurate.
            %
            %   This method can also be used when it is desirable to have complete
            %   control over which plugins are installed and in what order. It is the
            %   only method guaranteed to produce the minimal TestRunner with no
            %   plugins, so one can create it and add additional plugins as desired.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a silent TestRunner guaranteed to have no plugins
            %       runner = TestRunner.withNoPlugins;
            %       
            %       % Run the suite silently
            %       result = runner.run(suite)
            %
            %       % Control over which plugins are installed is maintained
            %       runner.addPlugin(MyCustomRunnerPlugin);
            %       runner.addPlugin(AnotherCustomPlugin);
            %
            %       % Run the suite with the custom plugins
            %       result = runner.run(suite)
            %
            %   See also: plugins.TestRunnerPlugin
            %
            
            import matlab.unittest.TestRunner;
            
            runner = TestRunner;
        end
        function runner = withTextOutput(varargin)
            % withTextOutput - Create a runner for command window output
            %
            %   RUNNER = matlab.unittest.TestRunner.withTextOutput creates a TestRunner
            %   that is configured for running tests from the Command Window and
            %   returns it in RUNNER. The output produced includes test progress as
            %   well as diagnostics in the event of test failures.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner that produced output to the Command Window
            %       runner = TestRunner.withTextOutput;
            %       
            %       % Run the suite
            %       result = runner.run(suite)
            %
            %   See also: TestSuite/run
            %
            
            import matlab.unittest.TestRunner;
            import matlab.unittest.Verbosity;
            import matlab.unittest.plugins.LoggingPlugin;
            import matlab.unittest.plugins.TestRunProgressPlugin;
            import matlab.unittest.plugins.FailureDiagnosticsPlugin;
            
            parser = TestRunner.WithTextOutputParser;
            parser.parse(varargin{:});
            
            runner = TestRunner;
            
            if any(strcmp(parser.UsingDefaults,'Verbosity'))
                runner.addPlugin(LoggingPlugin.withVerbosity(Verbosity.Terse));
                runner.addPlugin(TestRunProgressPlugin.withVerbosity(Verbosity.Concise));
            else
                runner.addPlugin(LoggingPlugin.withVerbosity(parser.Results.Verbosity));
                runner.addPlugin(TestRunProgressPlugin.withVerbosity(parser.Results.Verbosity));
            end
            
            runner.addPlugin(FailureDiagnosticsPlugin);
        end
    end
    
    methods
        function result = run(runner, suite)
            % RUN - Run all the tests in a TestSuite array
            %   
            %   RESULT = RUN(RUNNER, SUITE) runs the TestSuite defined by SUITE using
            %   the TestRunner provided in RUNNER, and returns the result in RESULT.
            %   RESULT is a matlab.unittest.TestResult which is the same size as SUITE,
            %   and each element is the result of the corresponding element in SUITE.
            %   This method ensures that tests written using the TestCase interface are
            %   correctly run. This includes running all of the appropriate methods of
            %   the TestCase class to set up fixtures and run test content. It ensures
            %   that errors and qualification failures are handled appropriately and
            %   their impacts are recorded into RESULTS.
            %
            %   Example:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.TestRunner;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       runner = TestRunner.withTextOutput;
            %
            %       result = runner.run(suite)
            %   
            %   See also: TestSuite, TestResult, TestCase, plugins.TestRunnerPlugin
            %            
            
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            % Delete handles to all plugin data instances before exiting
            % the run() method
            cleanupFixture = matlab.unittest.internal.Teardownable;
            cleanupFixture.addTeardown(@deletePluginData, runner);
            
            runner.TestRunData = matlab.unittest.internal.TestRunData(suite, createInitialTestResult(suite));
            runner.RunTestSuitePluginData = TestSuiteRunPluginData('', runner.TestRunData, numel(suite));
            runner.evaluateMethodOnPlugins(@runTestSuite, runner.RunTestSuitePluginData);
            result = runner.TestRunData.TestResult;
        end
        
        function addPlugin(runner, plugin)
            % addPlugin - Add a TestRunnerPlugin to a TestRunner
            %
            %   addPlugin(RUNNER, PLUGIN) adds the TestRunnerPlugin PLUGIN to the
            %   TestRunner RUNNER. Plugins are the mechanism provided to customize the
            %   manner in which a TestSuite is run.
            %
            %   Example:
            %
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins installed
            %       runner = TestRunner.withNoPlugins;
            %       
            %       % Add a custom plugin
            %       runner.addPlugin(MyCustomPlugin);
            %       result = runner.run(suite)
            %
            %   See also: plugins.TestRunnerPlugin
            %
            
            validateattributes(plugin, {'matlab.unittest.plugins.TestRunnerPlugin'}, {'scalar'}, '', 'plugin');
            runner.updatePluginHierarchy(plugin);                        
        end
        
    end
    
    methods %  Getters & Setters
        function instances = get.ActiveSharedFixtureInstances(runner)
            % Return the (possible empty) array of Fixture instances
            % corresponding to the ActiveSharedFixtures.
            instances = matlab.unittest.fixtures.EmptyFixture.empty;
            instances = [instances, runner.ActiveSharedFixtureStruct.Instance];
        end
        
        function instances = get.ActiveUserDefinedSharedFixtureInstances(runner)
            % Return the (possibly empty) array of user-specified Fixture
            % instances from the ActiveSharedFixturesStruct.
            mask = [runner.ActiveSharedFixtureStruct.UserDefined];
            instances = runner.ActiveSharedFixtureInstances(mask);
        end
        
        
        function result = get.CurrentResult(runner)
            result = runner.TestRunData.TestResult(runner.TestRunData.CurrentIndex);
        end
        function set.CurrentResult(runner, result)
            runner.TestRunData.TestResult(runner.TestRunData.CurrentIndex) = result;
        end
        
        function idx = get.CurrentIndex(runner)
            idx = runner.TestRunData.CurrentIndex;
        end
        function set.CurrentIndex(runner, idx)
            runner.TestRunData.CurrentIndex = idx;
        end
        
        function suite = get.CurrentSuite(runner)
            suite = runner.TestRunData.TestSuite(runner.CurrentIndex);
        end
    end
    
    methods(Access=private)
        function runner = TestRunner
            % Initialize raw plugin list
            runner.PluginList    = runner;
            
            % Initialize smart plugin heads to point to the runner instance
            % to begin with
            runner.PluginHeadMap = containers.Map; % Create a new map for each initialized TestRunner
            pluginMethodNames    = matlab.unittest.TestRunner.PluginMethodNames;
            for i = 1:numel(pluginMethodNames)
                runner.PluginHeadMap(pluginMethodNames{i}) = runner;
            end
        end
               
        function updatePluginHierarchy(runner, plugin)
            % Depending on methods the specified plugin has implemented,
            % update 
            %   1. Its set of "next" plugins, and
            %   2. TestRunner's smart plugin heads
            
            overriddenPluginMethodNames = findPluginMethodsOverriddenBy(plugin);
            runner.updatePluginHierarchyForOverriddenPluginMethods(plugin, overriddenPluginMethodNames);

            % Update raw plugin list
            runner.PluginList(end + 1) = plugin;
        end
        
        function updatePluginHierarchyForOverriddenPluginMethods(runner, plugin, pluginMethodNames)
            % Update the smart plugin heads of TestRunner and the "next"
            % plugin properties of the specified plugin

            for i = 1:numel(pluginMethodNames)
                thisMethodName = pluginMethodNames{i};
                plugin.(runner.NextPluginPropertyNameMap(thisMethodName)) = runner.PluginHeadMap(thisMethodName);
                runner.PluginHeadMap(thisMethodName) = plugin;
            end
        end
        
        function fixtures = getAllSharedFixturesForSuite(~, suite)
            fixtures = [suite.SharedTestFixtures, suite.InternalSharedTestFixtures];
        end
        
        function fixtures = getNextSharedFixtures(runner, suite)
            % Return the shared fixtures needed for suite(index+1)
            
            import matlab.unittest.fixtures.EmptyFixture;
            
            if runner.CurrentIndex < numel(suite)
                fixtures = runner.getAllSharedFixturesForSuite(suite(runner.CurrentIndex+1));
            else
                % Currently, pre-built fixtures are not supported, so there are no
                % fixtures required following the last element of the test suite.
                fixtures = EmptyFixture.empty;
            end
        end
        
        function runSharedTestCase(runner, pluginData)
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            cleanupFixture = matlab.unittest.internal.Teardownable;
            cleanupFixture.addTeardown(@teardownClassLevelTestCase, runner);
            
            % Get the subsuite from plugin data
            suite = pluginData.TestSuite;
            
            % prepare test class by creating a test class instance and
            % setting it up. It is OK to pass the first suite element since
            % they all belong to the same test class
            runner.prepareTestClass(suite(1));
            
            % If test class setup is incomplete, simply return, allowing
            % cleanupFixture to perform the teardown
            if runner.CurrentResult.Incomplete
                return;
            end
            
            % If test class setup is successful, then proceed with running
            % the individual tests
            for idx = 1:numel(suite)
                pluginData.CurrentIndex = idx;
                
                % Evaluate runTest()
                runner.RunTestPluginData = TestSuiteRunPluginData( ...
                    runner.CurrentResult.Name, runner.TestRunData, runner.CurrentIndex);
                
                runner.evaluateMethodOnPlugins(@runTest, runner.RunTestPluginData);
                
                % Delete RunTestPluginData as soon as we are done with it
                % for this iteration
                delete(runner.RunTestPluginData);
            end
            
            cleanupFixture.runAllTeardownThroughProcedure_( ...
                @(fcn,varargin)fcn(cleanupFixture, varargin{:}));
        end
        
        function endIndex = calculateSubsuiteWithinTestClassBoundary(runner, suite)
            % Calculate the subsuite of tests that belong to the same test class
            % with equivalent set of shared test fixtures. This subsuite falling
            % within the test class boundary will then be passed to runTestClass()
            % for execution. If the set of shared fixtures has changed, a new
            % TestClass is being run. The class name could be the same if two
            % different folders each contain classes with the same name. In that
            % case, only the fixtures are different.
            
            % Parent name and fixtures for the current suite
            expectedTestParentName = runner.CurrentSuite.TestParentName;
            expectedFixtures = runner.ActiveSharedFixtureInstances;
            
            endIndex = runner.CurrentIndex + 1;
            while endIndex <= numel(suite)
                thisSuite = suite(endIndex);
                
                % Different parent name
                if ~isequal(thisSuite.TestParentName, expectedTestParentName)
                    break;
                end
                
                fixturesForThisSuite = runner.getAllSharedFixturesForSuite(thisSuite);
                
                % Different fixtures (need to set up fixtures)
                if ~isempty(getTestFixturesToSetup(expectedFixtures, fixturesForThisSuite))
                    break;
                end
                
                % Different fixtures (need to tear down fixtures)
                if ~isempty(getFirstFixtureToTeardown(expectedFixtures, fixturesForThisSuite))
                    break;
                end
                
                endIndex = endIndex + 1;
            end
            
            endIndex = endIndex - 1;
        end
        
        function suiteEndIdx = calculateSubsuiteWithinSharedTestCaseBoundary(~, suite, suiteStartIdx)
            % Calculate the subsuite of tests that belong to the same test
            % class with same class setup parameterization. This subsuite
            % falling within the shared test case boundary will then be
            % passed to runSharedTestCase() for execution.

            currentClassSetupParams = suite(suiteStartIdx).Parameterization.filterByClass( ...
                'matlab.unittest.parameters.ClassSetupParameter');
                        
            suiteEndIdx = suiteStartIdx + 1;
            while suiteEndIdx <= numel(suite)
                % Find all tests that share class setup parameters
                nextClassSetupParams = suite(suiteEndIdx).Parameterization.filterByClass( ...
                    'matlab.unittest.parameters.ClassSetupParameter');
                
                if ~isequal({nextClassSetupParams.Name}, {currentClassSetupParams.Name})
                    break;
                end
                
                suiteEndIdx = suiteEndIdx + 1;
            end
            
            suiteEndIdx = suiteEndIdx - 1;
        end
        
        function prepareSharedTestFixtures(runner)
            % Create and set up fixtures that are required but are not yet
            % set up (an element of the ActiveSharedFixtureStruct array).
            
            import matlab.unittest.plugins.plugindata.PluginData
            import matlab.unittest.plugins.plugindata.SharedTestFixturePluginData
            
            [requiredFixtures, userFixtureMask] = runner.determineSharedFixturesToSetup();
            
            for idx = 1:numel(requiredFixtures)
                fixtureClass = metaclass(requiredFixtures(idx));
                
                runner.RequiredSharedTestFixtureToSetup    = requiredFixtures(idx);
                runner.SharedTestFixtureCreationPluginData = PluginData(fixtureClass.Name);
                
                isUserDefined = userFixtureMask(idx);
                
                if isUserDefined
                    fixture = runner.evaluateMethodOnPlugins(@createSharedTestFixture, runner.SharedTestFixtureCreationPluginData);
                else
                    fixture = runner.createInternalSharedTestFixture(runner.SharedTestFixtureCreationPluginData);
                end
                
                % Delete SharedTestFixtureCreationPluginData as soon as we are done with it.
                delete(runner.SharedTestFixtureCreationPluginData);
                
                % Update the ActiveSharedFixtureStruct with the newly constructed fixture
                runner.ActiveSharedFixtureStruct(end + 1) = struct(...
                    'Instance'   , fixture, ...
                    'UserDefined', isUserDefined, ...
                    'StartIndex' , runner.CurrentIndex);
                
                if isUserDefined
                    runner.SetupSharedTestFixturePluginData = SharedTestFixturePluginData(fixtureClass.Name, fixture.SetupDescription);
                    runner.evaluateMethodOnPlugins(@setupSharedTestFixture, runner.SetupSharedTestFixturePluginData);
                    
                    % Delete SetupSharedTestFixturePluginData as soon as we are done with it.
                    delete(runner.SetupSharedTestFixturePluginData);
                else
                    runner.setupInternalSharedTestFixture();
                end
                
                % If an active shared fixture setup did not complete, don't
                % continue setting up any more fixtures.
                if runner.CurrentResult.Incomplete
                    break;
                end
            end
        end
        
        function testCase = prepareSharedFixturesForTestCase(runner, testCase)
            
            % Let the TestCase know about the user-specified active shared fixtures
            testCase.SharedTestFixtures_ = runner.ActiveUserDefinedSharedFixtureInstances;
            
            % Let all the fixtures know about the TestCase
            for fixture = [runner.ActiveSharedFixtureInstances, testCase.TestFixturesFromApplyFixture_]
                fixture.applyTestCase(testCase);
            end
        end
        
        function prepareTestClass(runner, test)
            
            import matlab.unittest.plugins.plugindata.PluginData;
            
            runner.TestClassPluginData  = PluginData(test.SharedTestClassName);
            classLevelTestCase = runner.evaluateMethodOnPlugins(@createTestClassInstance, runner.TestClassPluginData);
            
            % Determine the TestMethodSetup and TestMethodTeardown methods that
            % need to be run for each Test method in the class. Base class
            % methods first for TestMethodSetup; derived class methods first
            % for TestMethodTeardown.
            setupMethods = findobj(test.TestClass.MethodList, 'TestMethodSetup', true);
            teardownMethods = rot90(findobj( ...
                test.TestClass.MethodList, 'TestMethodTeardown', true), 2);
            
            runner.ClassLevelStruct = struct(...
                'TestCase'       , classLevelTestCase, ...
                'SetupMethods'   , setupMethods, ...
                'TeardownMethods', teardownMethods);
            
            runner.evaluateMethodOnPlugins(@setupTestClass, runner.TestClassPluginData);
        end
        
        function [toSetup, userMask] = determineSharedFixturesToSetup(runner)
            
            % The required fixtures are all the internal and user fixtures
            % defined for the suite element.
            internalFixtures = runner.CurrentSuite.InternalSharedTestFixtures;
            userFixtures = runner.CurrentSuite.SharedTestFixtures;
            requiredSharedFixtures = [userFixtures, internalFixtures];
            userMask = [true(size(userFixtures)), false(size(internalFixtures))];
            
            toSetupIdx = getTestFixturesToSetup( ...
                runner.ActiveSharedFixtureInstances, requiredSharedFixtures);
            
            toSetup = requiredSharedFixtures(toSetupIdx);
            userMask = userMask(toSetupIdx);
        end
        
        function teardownAllSharedFixturesExcluding(runner, fixturesToKeep)
            import matlab.unittest.plugins.plugindata.SharedTestFixturePluginData;
            
            % Tear down the fixtures that are no longer required.
            
            fixtureIndex = getFirstFixtureToTeardown(runner.ActiveSharedFixtureInstances, fixturesToKeep);
            while numel(runner.ActiveSharedFixtureInstances) >= fixtureIndex
                
                % Grab the last instance to tear down in reverse order
                fixture = runner.ActiveSharedFixtureStruct(end).Instance;
                fixtureClass = metaclass(fixture);
                
                % Register teardown to remove the fixture from the
                % ActiveSharedFixtureStruct in case the fixture teardown fatally asserts.
                cleanupFixture = matlab.unittest.internal.Teardownable;
                cleanupFixture.addTeardown(@removeLastFixtureFromActiveSharedFixtureStruct, runner);
                cleanupFixture.addTeardown(@delete, fixture);
                
                % Tear down the fixture
                if runner.ActiveSharedFixtureStruct(end).UserDefined
                    runner.TeardownSharedTestFixturePluginData = SharedTestFixturePluginData(fixtureClass.Name, fixture.TeardownDescription);
                    runner.evaluateMethodOnPlugins(@teardownSharedTestFixture, runner.TeardownSharedTestFixturePluginData);
                    
                    % Delete TeardownSharedTestFixturePluginData as soon as we are done with it
                    delete(runner.TeardownSharedTestFixturePluginData);
                else
                    % Directly tear down the internal fixture, bypassing the plugins
                    fixture.runAllTeardownThroughProcedure_( ...
                        @(fcn,varargin)fcn(fixture, varargin{:}));
                end
                
                delete(cleanupFixture);
            end
        end
        
        function removeLastFixtureFromActiveSharedFixtureStruct(runner)
            runner.ActiveSharedFixtureStruct(end) = [];
        end
        
        function setupInternalSharedTestFixture(runner, ~)
            % Directly set up the internal fixture, bypassing the plugins
            fixture = runner.ActiveSharedFixtureInstances(end);
            registerTeardown = onCleanup(@()fixture.addTeardown(@teardown, fixture));
            fixture.setup();
        end
        
        function teardownClassLevelTestCase(runner)
            % We may have reached here due to an error while creating a
            % class level testcase instance. In that case, we don't need to
            % go through the teardown process at all.
            if ~isempty(runner.ClassLevelStruct.TestCase)
                runner.evaluateMethodOnPlugins(@teardownTestClass, runner.TestClassPluginData);
                delete(runner.ClassLevelStruct.TestCase);
                runner.ClassLevelStruct.TestCase = [];
            end
            
            % Delete TestClassPluginData as soon as we are done with it
            delete(runner.TestClassPluginData);
        end
        
        function recordSharedTestFixtureSetupFailure(runner, property)
            % Determine when a shared test fixture needs to be torn down
            % and apply the setup results to all indices from the current
            % index through the last index that uses the fixture.
            
            suite = runner.TestRunData.TestSuite;
            activeFixtures = runner.ActiveSharedFixtureInstances;
            
            % The index of the fixture we just set up that had a failure.
            fixtureIdx = numel(activeFixtures);
            
            endIdx = runner.CurrentIndex;
            while endIdx < numel(suite)
                endIdx = endIdx + 1;
                
                % We don't care about any of the fixtures that would have been
                % set up after the fixture that had a failure (including
                % InternalSharedTestFixtures). Those fixtures would have to
                % have been torn down no later than this failing fixture.
                toTeardownIdx = getFirstFixtureToTeardown( ...
                    activeFixtures, suite(endIdx).SharedTestFixtures);
                
                if toTeardownIdx <= fixtureIdx
                    % We need to tear down the fixture for this suite index.
                    % The setup results apply to all elements up to this
                    % point, but not including it.
                    endIdx = endIdx - 1;
                    break;
                end
            end
            
            [runner.TestRunData.TestResult(runner.CurrentIndex:endIdx).(property)] = deal(true);
            
            % Update the current index so that the teardown results will be
            % applied to the correct element.
            runner.CurrentIndex = endIdx;
        end
        
        function recordSharedTestFixtureTeardownFailure(runner, property)
            % Apply the failure results from tearing down a shared test fixture.
            [runner.TestRunData.TestResult(runner.ActiveSharedFixtureStruct(end).StartIndex:runner.CurrentIndex).(property)] = deal(true);
        end
        
        function recordSharedTestCaseFailure(runner, property)
            % Apply the failure results from setting up or tearing down a
            % shared test case.
            [runner.RunSharedTestCasePluginData.TestResult.(property)] = deal(true);
        end
        
        function recordSharedTestCaseFailureAndUpdateCurrentIndex(runner, property)
            runner.recordSharedTestCaseFailure(property);
            
            % Also update the current index so that the teardown results
            % will be applied to the correct element.
            runner.RunSharedTestCasePluginData.CurrentIndex = numel(runner.RunSharedTestCasePluginData.TestSuite);
        end
        
        function recordTestMethodFailure(runner, property)
            % Apply the failure results from a single test method (includes
            % test method setup, the test method itself, and test method teardown).
            runner.CurrentResult.(property) = true;
        end
        
        function varargout = evaluateMethodOnPlugins(runner, method, varargin)
            
            runner.HasExecutedFullPluginStack = false;
            
            % Run the method
            [varargout{1:nargout}] = method(runner.PluginHeadMap(func2str(method)), varargin{:});
            
            if ~runner.HasExecutedFullPluginStack
                error(message('MATLAB:unittest:TestRunner:MustCallSuperclassMethod'));
            end
        end
        
        function evaluateMethodsOnTestContent(runner, methods, content)
            % Run methods on test content going through the plugin methods.
            % Handle any exceptions thrown by the test content.
            
            for idx = numel(methods):-1:1
                arguments = runner.CurrentSuite.Parameterization.getInputsFor(methods(idx));
                runner.evaluateMethodOnPlugins(@evaluateMethod, methods(idx), content, arguments);
            end
        end
        
        function evaluateTeardownMethodOnPlugins(runner, content, fcn, varargin)
            method = identifyMetaMethod(metaclass(content), func2str(fcn));
            runner.evaluateMethodOnPlugins(@evaluateMethod, method, content, varargin);
        end
        
        function deletePluginData(runner)
            % helper function to delete all PluginData handles          
            delete(runner.RunTestMethodPluginData);
            delete(runner.TestMethodPluginData);
            delete(runner.RunTestPluginData);
            delete(runner.TestClassPluginData);
            delete(runner.RunSharedTestCasePluginData);
            delete(runner.RunTestClassPluginData);
            delete(runner.RunTestSuitePluginData);
            delete(runner.TeardownSharedTestFixturePluginData);
            delete(runner.SetupSharedTestFixturePluginData);
            delete(runner.SharedTestFixtureCreationPluginData);
        end
    end
    
    
    methods(Hidden, Access=protected) % conform to TestContentOperator API
        function runTestSuite(runner, pluginData)
            import matlab.unittest.fixtures.EmptyFixture;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('runTestSuite', pluginData, runner.RunTestSuitePluginData);
            
            % For exception safety, tear down any fixtures active at the
            % time of a fatal assertion failure.
            teardownFixtures = matlab.unittest.internal.Teardownable;
            teardownFixtures.addTeardown(@teardownAllSharedFixturesExcluding, ...
                runner, runner.ActiveSharedFixtureInstances);
            
            % Get the initial test suite from plugin data
            suite = pluginData.TestSuite;
            
            runner.CurrentIndex = 0;
            while runner.CurrentIndex < numel(suite)
                runner.CurrentIndex = runner.CurrentIndex + 1;
                
                % Set up any required fixtures that aren't already set up.
                runner.prepareSharedTestFixtures();
                
                % If shared test fixture is incomplete, we don't run the tests
                % that are under that shared test fixture umbrella. We do,
                % however, tear down any unneeded shared test fixtures.
                if ~runner.CurrentResult.Incomplete
                    % Calculate the subsuite within the test class boundary - this
                    % includes all tests that belong to the same test class and has
                    % the same set of shared test fixtures.
                    suiteEndIdx = calculateSubsuiteWithinTestClassBoundary(runner, suite);
                    
                    % Evaluate runTestClass()
                    runner.RunTestClassPluginData = TestSuiteRunPluginData( ...
                        runner.CurrentSuite.TestParentName, runner.TestRunData, suiteEndIdx);
                    
                    runner.evaluateMethodOnPlugins(@runTestClass, runner.RunTestClassPluginData);
                    
                    % Delete RunTestClassPluginData for this iteration
                    delete(runner.RunTestClassPluginData);
                end
                
                % Tear down fixture no longer needed.
                runner.teardownAllSharedFixturesExcluding(runner.getNextSharedFixtures(suite));
            end
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function fixture = createSharedTestFixture(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('createSharedTestFixture', pluginData, runner.SharedTestFixtureCreationPluginData);
            
            fixture = copy(runner.RequiredSharedTestFixtureToSetup);
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function fixture = createInternalSharedTestFixture(runner, ~)
            fixture = copy(runner.RequiredSharedTestFixtureToSetup);
        end
        
        function setupSharedTestFixture(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('setupSharedTestFixture', pluginData, runner.SetupSharedTestFixturePluginData);
            
            fixture = runner.ActiveSharedFixtureInstances(end);
            fixtureClass = metaclass(fixture);
            
            setupMethod = identifyMetaMethod(fixtureClass, 'setup');
            
            runner.ApplyFailureFunction = @runner.recordSharedTestFixtureSetupFailure;
            runner.evaluateMethodsOnTestContent(setupMethod, fixture);
            
            % Update the description which the fixture may have set during setup
            runner.SetupSharedTestFixturePluginData.Description = fixture.SetupDescription;
            
            teardownMethod = identifyMetaMethod(fixtureClass, 'teardown');
            registerTeardownMethods(fixture, teardownMethod);
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function runTestClass(runner, pluginData)
            import matlab.unittest.fixtures.EmptyFixture;
            import matlab.unittest.plugins.plugindata.PluginData;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
                       
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('runTestClass', pluginData, runner.RunTestClassPluginData);
            
            % Get the subsuite from plugin data
            suite = pluginData.TestSuite;
            
            startIdx = runner.CurrentIndex;
            pluginData.CurrentIndex = 0;
            while pluginData.CurrentIndex < numel(suite)
                pluginData.CurrentIndex = pluginData.CurrentIndex + 1;
                
                % Calculate the subsuite within the shared test case boundary -
                % this includes all tests that belong to the same test class
                % and have same class setup parameterization.
                suiteEndIdx = calculateSubsuiteWithinSharedTestCaseBoundary(runner, suite, pluginData.CurrentIndex);

                % Construct plugin data to be passed into runSharedTestCase
                runner.RunSharedTestCasePluginData = TestSuiteRunPluginData( ...
                    '', runner.TestRunData, startIdx+suiteEndIdx-1);
                
                % Evaluate runSharedTestCase() method
                runner.runSharedTestCase(runner.RunSharedTestCasePluginData);
                
                % Delete RunSharedTestCasePluginData as soon as we are done
                % with it for this iteration
                delete(runner.RunSharedTestCasePluginData);
            end
            
            runner.HasExecutedFullPluginStack = true;
        end    
                  
        function testCase = createTestClassInstance(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('createTestClassInstance', pluginData, runner.TestClassPluginData);
            
            % create a class level testcase instance
            testCase = copy(runner.CurrentSuite.TestCase);
            
            runner.ApplyFailureFunction = @runner.recordSharedTestCaseFailureAndUpdateCurrentIndex;
            testCase.addlistener('VerificationFailed', @(~,~)runner.recordSharedTestCaseFailure('VerificationFailed'));
            
            testCase = runner.prepareSharedFixturesForTestCase(testCase);
            
            runner.HasExecutedFullPluginStack = true;
        end        
        
        function setupTestClass(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('setupTestClass', pluginData, runner.TestClassPluginData);
            
            testCase  = runner.ClassLevelStruct.TestCase;
            testClass = metaclass(testCase);
            testClassSetup = findobj(testClass.MethodList, 'TestClassSetup', true);
            
            runner.evaluateMethodsOnTestContent(testClassSetup, testCase);
            
            testClassTeardown = rot90(findobj(testClass.MethodList, 'TestClassTeardown', true), 2);
            registerTeardownMethods(testCase, testClassTeardown);
            
            runner.HasExecutedFullPluginStack = true;
        end
                
        function runTest(runner, pluginData)
            import matlab.unittest.plugins.plugindata.PluginData;
            import matlab.unittest.plugins.plugindata.TestSuiteRunPluginData;
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('runTest', pluginData, runner.RunTestPluginData);
            
            runner.TestMethodPluginData = PluginData(runner.CurrentResult.Name);
            
            % Create method level testcase
            runner.CurrentMethodLevelTestCase = runner.evaluateMethodOnPlugins(@createTestMethodInstance, runner.TestMethodPluginData);
            
            % Teardown current method level testcase
            cleanupFixture = matlab.unittest.internal.Teardownable;
            cleanupFixture.addTeardown(@delete, runner.CurrentMethodLevelTestCase);
            
            % Evaluate setup test method
            runner.evaluateMethodOnPlugins(@setupTestMethod, runner.TestMethodPluginData);
            
            % Only run if we have completed our fixture setup
            if ~runner.CurrentResult.Incomplete
                % Run the Test method.
                runner.RunTestMethodPluginData = TestSuiteRunPluginData( ...
                    runner.CurrentResult.Name, runner.TestRunData, runner.CurrentIndex);
                runner.evaluateMethodOnPlugins(@runTestMethod, runner.RunTestMethodPluginData);
            end
            
            % Tear down the fresh fixture.
            runner.evaluateMethodOnPlugins(@teardownTestMethod, runner.TestMethodPluginData);
            
            % Delete unneeded plugin data as soon as we are done with them
            delete(runner.TestMethodPluginData);
            delete(runner.RunTestMethodPluginData);
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function testCase = createTestMethodInstance(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('createTestMethodInstance', pluginData, runner.TestMethodPluginData);
            
            % Create the testCase instance from the class level prototype
            testCase = runner.CurrentSuite.createTestCaseFromClassPrototype(runner.ClassLevelStruct.TestCase);
            
            runner.ApplyFailureFunction = @runner.recordTestMethodFailure;
            testCase.addlistener('VerificationFailed', @(~,~)runner.recordTestMethodFailure('VerificationFailed'));
            
            testCase = runner.prepareSharedFixturesForTestCase(testCase);
            
            runner.HasExecutedFullPluginStack = true;
        end

        function setupTestMethod(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('setupTestMethod', pluginData, runner.TestMethodPluginData);   
            
            testCase = runner.CurrentMethodLevelTestCase;
            runner.evaluateMethodsOnTestContent(runner.ClassLevelStruct.SetupMethods, testCase);
            registerTeardownMethods(testCase, runner.ClassLevelStruct.TeardownMethods);
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function runTestMethod(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('runTestMethod', pluginData, runner.RunTestMethodPluginData);   
            
            runner.CurrentResult.Started  = true;
            testCase = runner.CurrentMethodLevelTestCase;
            runner.evaluateMethodsOnTestContent(pluginData.TestSuite.TestMethod, testCase);
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function evaluateMethod(runner, method, content, arguments)
            % Run a method, record its duration, and apply any failure results.
            
            import matlab.unittest.qualifications.ExceptionEventData;
            
            methodName = method.Name;
            
            try
                t0 = tic;
                feval(methodName, content, arguments{:});
                duration = toc(t0);
                runner.CurrentResult.Duration = runner.CurrentResult.Duration + duration;
            catch exception
                duration = toc(t0);
                runner.CurrentResult.Duration = runner.CurrentResult.Duration + duration;
                
                exceptionClass = metaclass(exception);
                if exceptionClass <= ?matlab.unittest.qualifications.FatalAssertionFailedException
                    rethrow(exception);
                elseif exceptionClass <= ?matlab.unittest.qualifications.AssertionFailedException
                    runner.ApplyFailureFunction('AssertionFailed');
                elseif exceptionClass <= ?matlab.unittest.qualifications.AssumptionFailedException
                    runner.ApplyFailureFunction('AssumptionFailed');
                else
                    content.notify('ExceptionThrown', ExceptionEventData(exception));
                    runner.ApplyFailureFunction('Errored');
                end
            end
            
            runner.HasExecutedFullPluginStack = true;
        end        
        
        function teardownTestMethod(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('teardownTestMethod', pluginData, runner.TestMethodPluginData);   
            
            testCase = runner.CurrentMethodLevelTestCase;
            testCase.runAllTeardownThroughProcedure_( ...
                @(varargin)runner.evaluateTeardownMethodOnPlugins(testCase, varargin{:}))
            
            runner.HasExecutedFullPluginStack = true;
        end          
        
        function teardownTestClass(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('teardownTestClass', pluginData, runner.TestClassPluginData);
            
            testCase = runner.ClassLevelStruct.TestCase;
            
            runner.ApplyFailureFunction = @runner.recordSharedTestCaseFailure;
            testCase.runAllTeardownThroughProcedure_( ...
                @(varargin)runner.evaluateTeardownMethodOnPlugins(testCase, varargin{:}));
            
            runner.HasExecutedFullPluginStack = true;
        end
        
        function teardownSharedTestFixture(runner, pluginData)
            
            % Validate the plugin data that made its way back to TestRunner
            % after going through all the plugins
            checkPluginDataEquality('teardownSharedTestFixture', pluginData, runner.TeardownSharedTestFixturePluginData);
            
            fixture = runner.ActiveSharedFixtureStruct(end).Instance;
            
            runner.ApplyFailureFunction = @runner.recordSharedTestFixtureTeardownFailure;
            fixture.runAllTeardownThroughProcedure_( ...
                @(varargin)runner.evaluateTeardownMethodOnPlugins(fixture, varargin{:}));
            
            % Update the description which the fixture may have set during teardown
            runner.TeardownSharedTestFixturePluginData.Description = fixture.TeardownDescription;
            
            runner.HasExecutedFullPluginStack = true;
        end
        
    end
    
    methods (Hidden, Static)
        function runner = loadobj(savedRunner)
            import matlab.unittest.TestRunner;
            
            % Create a new runner and copy over only the plugins; all other
            % state can be considered transient.
            runner = TestRunner;
            for idx = 2:numel(savedRunner.PluginList)
                runner.addPlugin(savedRunner.PluginList(idx));
            end
        end
    end
end


function metaMethod = identifyMetaMethod(metaClass, name)
metaMethod = findobj(metaClass.MethodList, 'Name', name);
end

function registerTeardownMethods(content, methods)
import matlab.unittest.internal.TeardownElement;

for idx = 1:numel(methods)
    content.addTeardown(TeardownElement(str2func(methods(idx).Name), {}));
end
end

function checkPluginDataEquality(methodName, actualPluginData, expectedPluginData)
% Handle equality check on plugin data that made its way back to TestRunner
% after going through all the plugins
if actualPluginData ~= expectedPluginData
    error(message('MATLAB:unittest:TestRunner:PluginDataMismatch', methodName));
end
end

function result = createInitialTestResult(suite)
% Creates an initial TestResult that is of the same size as the suite
% passed in and transferring the suite element name
import matlab.unittest.TestResult;

result = TestResult.empty;
numElements = numel(suite);
% Create the initial test result with right size & shape
if numElements > 0
    result(numElements) = TestResult;
end
result = reshape(result, size(suite));

for idx = 1:numElements
    result(idx).Name = suite(idx).Name;
end
end

function keys = getPluginMethodNames()
keys = {...
    'runTestSuite', ...
    'runTestClass', ...
    'runTest', ...
    'runTestMethod', ...
    'createSharedTestFixture', ...
    'createTestClassInstance', ...
    'createTestMethodInstance', ...
    'setupSharedTestFixture', ...
    'teardownSharedTestFixture', ...
    'setupTestClass', ...
    'teardownTestClass', ...
    'setupTestMethod', ...
    'teardownTestMethod', ...
    'evaluateMethod', ...
    };
end

function map = createNextPluginPropertyNameMap()
keySet = matlab.unittest.TestRunner.PluginMethodNames;
valueSet  = {...
    'NextRunTestSuitePlugin', ...
    'NextRunTestClassPlugin', ...
    'NextRunTestPlugin', ...
    'NextRunTestMethodPlugin', ...
    'NextCreateSharedTestFixturePlugin', ...
    'NextCreateTestClassInstancePlugin', ...
    'NextCreateTestMethodInstancePlugin', ...
    'NextSetupSharedTestFixturePlugin', ...
    'NextTeardownSharedTestFixturePlugin', ...
    'NextSetupTestClassPlugin', ...
    'NextTeardownTestClassPlugin', ...
    'NextSetupTestMethodPlugin', ...
    'NextTeardownTestMethodPlugin', ...
    'NextEvaluateMethodPlugin', ...
    };
map = containers.Map(keySet, valueSet);
end

function pluginMethodNames = findPluginMethodsOverriddenBy(plugin)
pluginClass = metaclass(plugin);
allPluginMethodNames = matlab.unittest.TestRunner.PluginMethodNames;

mask = false(size(allPluginMethodNames));
for idx = 1:numel(allPluginMethodNames)
    pluginMethod = pluginClass.MethodList.findobj('Name', allPluginMethodNames{idx});
    mask(idx) = pluginMethod.DefiningClass ~= ?matlab.unittest.plugins.TestRunnerPlugin;
end
pluginMethodNames = allPluginMethodNames(mask);
end

function parser = createWithTextOutputParser
import matlab.unittest.Verbosity;

parser = inputParser;
parser.PartialMatching = false;
parser.CaseSensitive = true;
parser.StructExpand = false;
parser.addParameter('Verbosity', []);
end

% LocalWords:  mypackage func Teardownable
% LocalWords:  mypackage func Teardownable plugindata subsuite
