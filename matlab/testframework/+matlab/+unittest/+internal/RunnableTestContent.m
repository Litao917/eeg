classdef(Hidden) RunnableTestContent < matlab.unittest.internal.TestContent & ...
                                       matlab.unittest.internal.qualifications.ThrowingQualifiable & ...
                                       matlab.unittest.qualifications.Verifiable
    % Undocumented.
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    
    properties (Access={?matlab.unittest.TestRunner})
        SharedTestFixtures_ = matlab.unittest.fixtures.EmptyFixture.empty;
        TestFixturesFromApplyFixture_ = matlab.unittest.fixtures.EmptyFixture.empty;
    end
    
    properties(Constant, Access=private)
        DiagnosticCatalog = matlab.internal.Catalog('MATLAB:unittest:Diagnostic'); 
        InteractiveCatalog = matlab.internal.Catalog('MATLAB:unittest:Interactive');        
     end
    
    
    methods
        function runnableContent = RunnableTestContent
            % Add passing listeners
            runnableContent.addlistener('VerificationPassed'  , @runnableContent.handlePassingInteractiveVerification);
            runnableContent.addlistener('AssertionPassed'     , @runnableContent.handlePassingInteractiveAssertion);
            runnableContent.addlistener('FatalAssertionPassed', @runnableContent.handlePassingInteractiveFatalAssertion);
            runnableContent.addlistener('AssumptionPassed'    , @runnableContent.handlePassingInteractiveAssumption);
            
            % Add failing listeners
            runnableContent.addlistener('VerificationFailed'  , @runnableContent.handleFailingInteractiveVerification);
            runnableContent.addlistener('AssertionFailed'     , @runnableContent.handleFailingInteractiveAssertion);
            runnableContent.addlistener('FatalAssertionFailed', @runnableContent.handleFailingInteractiveFatalAssertion);
            runnableContent.addlistener('AssumptionFailed'    , @runnableContent.handleFailingInteractiveAssumption);
            
            % Add diagnostic logging listener
            runnableContent.addlistener('DiagnosticLogged', @runnableContent.handleDiagnosticLogged);
        end
    end
    
    methods(Static)

        function testCase = forInteractiveUse
            % forInteractiveUse - Create a TestCase to use interactively.
            %   TESTCASE = TestCase.forInteractiveUse creates a TestCase instance that
            %   is configured for experimentation at the MATLAB Command Prompt.
            %   TESTCASE is a matlab.unittest.TestCase instance that reacts to
            %   qualificaton failures and successes by printing messages to standard
            %   output (the screen) for both passing and failing conditions.
            %
            %   Examples:
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase configured for interactive use at the MATLAB
            %       % Command Prompt.
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Produce a passing verification.
            %       testCase.verifyTrue(true, 'true should be true');
            %
            %       % Produce a failing verification.
            %       testCase.verifyTrue(false);
            testCase = matlab.unittest.TestCase;
        end
    end
    
    methods(Sealed)
        function result = run(testCase, varargin)
            % RUN - Run a TestCase test.
            %
            %   RESULT = RUN(TESTCASE) uses TESTCASE as a prototype to run a TestSuite
            %   created from all test methods in the class defining TESTCASE. This
            %   suite is run using a TestRunner configured for text output. RESULT is a
            %   matlab.unittest.TestResult containing the result of the test run.
            %
            %   RESULT = RUN(TESTCASE, TESTMETHOD) uses TESTCASE as a prototype to run
            %   a TestSuite created from TESTMETHOD. TESTMETHOD is either the name of
            %   the desired test method as a string or the meta.method instance which
            %   describes the desired test method. The method must correspond to a
            %   valid Test method of the TESTCASE instance. This test is run using a
            %   TestRunner configured for text output. RESULT is a
            %   matlab.unittest.TestResult containing the result of the test run.
            %
            %   This is a convenience method to allow interactive experimentation of
            %   TestCase classes in MATLAB, yet running the tests contained in them
            %   using a supported TestRunner.
            %
            %   Example:
            %
            %       testCase = mypackage.MyTestClass; 
            %       
            %       % Run all tests in mypackage.MyTestClass
            %       allResults = run(testCase);
            %
            %       % Run the "testSomething" method in the mypackage.MyTestClass
            %       testSomethingResult = run(testCase, 'testSomething');
            %
            %   See also: TestRunner, TestSuite, TestResult
            import matlab.unittest.Test;
            
            suite = Test.fromTestCase(testCase, varargin{:});
            result = run(suite);
        end
        
        function fixture = applyFixture(testCase, fixture)
            % applyFixture - Use a fixture within a TestCase class.
            %
            %   applyFixture(TESTCASE, FIXTURE) sets up FIXTURE for use with TESTCASE.
            %   This method allows a fixture to be used within the scope of a single
            %   Test method or TestCase class. Call applyFixture within a Test method
            %   to use a fixture for that Test method alone. Use applyFixture within a
            %   TestClassSetup method to set up a fixture for the entire class.
            %
            %   By using applyFixture, the lifecycle of FIXTURE is tied to that of
            %   TESTCASE. When TESTCASE is torn down or deleted, FIXTURE is also torn
            %   down.
            %
            %   Example:
            %
            %       classdef TSomeTest < matlab.unittest.TestCase
            %           methods(TestMethodSetup)
            %               function addHelpersToPath(testCase)
            %                   import matlab.unittest.fixtures.PathFixture;
            %                   testCase.applyFixture(PathFixture('testHelpers'));
            %               end
            %           end
            %       end
            %
            
            import matlab.unittest.internal.TestContentDelegateSubstitutor;
            
            validateattributes(fixture, {'matlab.unittest.fixtures.Fixture'}, {'scalar'}, '', 'fixture');
            
            % Keep track of the fixtures that are applied to the TestCase instance.
            testCase.TestFixturesFromApplyFixture_ = [testCase.TestFixturesFromApplyFixture_, fixture];
            
            % Provide the TestCase as the Fixture's qualifiable so that
            % qualification failures in the fixture are reported on the
            % TestCase. Transfer the teardown delegate so that teardown
            % content added to the fixture is registered on the TestCase.
            TestContentDelegateSubstitutor.substituteFixtureQualifiable(testCase, fixture);
            TestContentDelegateSubstitutor.transferTeardownDelegate(testCase, fixture);
            
            % Let the fixture know about the TestCase it's being used with.
            fixture.applyTestCase(testCase);
            
            % Teardown should be registered after setup is invoked, and
            % even if setup throws an exception and does not complete.
            registerTeardown = onCleanup(@()testCase.addTeardown(@teardown, fixture));
            fixture.setup();
        end
        
        function fixtures = getSharedTestFixtures(testCase, fixtureClassName)
            % getSharedTestFixtures - Access shared test fixtures.
            %
            %   FIXTURES = getSharedTestFixtures(TESTCASE) returns in FIXTURES the
            %   array of all shared test fixtures that have been set up for TESTCASE.
            %   Shared test fixtures are specified using the SharedTestFixtures class
            %   attribute.
            %
            %   FIXTURES = getSharedTestFixtures(TESTCASE, FIXTURECLASSNAME) returns
            %   in FIXTURES only those shared test fixtures whose class name is
            %   FIXTURECLASSNAME.
            %
            %   Example:
            %
            %       classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture('testHelpers')}) ...
            %               TSomeTest < matlab.unittest.TestCase
            %           methods(Test)
            %               function accessPathFixture(testCase)
            %                   pathFixture = testCase.getSharedTestFixtures('matlab.unittest.fixtures.PathFixture');
            %                   folderOnPath = pathFixture.Folder;
            %               end
            %           end
            %       end
            %
            
            fixtures = testCase.SharedTestFixtures_;
            
            if nargin > 1
                fixtureClasses = arrayfun(@class, fixtures, 'UniformOutput',false);
                fixtures = fixtures(strcmp(fixtureClasses, fixtureClassName));
            end
        end
    end
    
    methods(Access=private)
        function handlePassingInteractiveVerification(runnableContent, varargin)
            printLine(getString(runnableContent.InteractiveCatalog, 'VerificationPassed'));
        end
        function handlePassingInteractiveAssertion(runnableContent, varargin)
            printLine(getString(runnableContent.InteractiveCatalog, 'AssertionPassed'));
        end
        function handlePassingInteractiveFatalAssertion(runnableContent, varargin)
            printLine(getString(runnableContent.InteractiveCatalog, 'FatalAssertionPassed'));
        end
        function handlePassingInteractiveAssumption(runnableContent, varargin)
            printLine(getString(runnableContent.InteractiveCatalog, 'AssumptionPassed'));
        end
        
        function handleFailingInteractiveVerification(runnableContent, ~, evd)
            printLine(getString(runnableContent.InteractiveCatalog, 'VerificationFailed'));
            runnableContent.printDiagnosticsFromEventData(evd);          
        end
        function handleFailingInteractiveAssertion(runnableContent,  ~, evd)
            printLine(getString(runnableContent.InteractiveCatalog, 'AssertionFailed'));
            runnableContent.printDiagnosticsFromEventData(evd);          
        end
        function handleFailingInteractiveFatalAssertion(runnableContent,  ~, evd)
            printLine(getString(runnableContent.InteractiveCatalog, 'FatalAssertionFailed'));
            runnableContent.printDiagnosticsFromEventData(evd);          
        end
        function handleFailingInteractiveAssumption(runnableContent,  ~, evd)
            printLine(getString(runnableContent.InteractiveCatalog, 'AssumptionFailed'));
            runnableContent.printDiagnosticsFromEventData(evd);          
        end
        
        function handleDiagnosticLogged(runnableContent, ~, evd)
            printLine(getString(runnableContent.InteractiveCatalog, 'DiagnosticLogged'));
            diagResults = evd.DiagnosticResult;
            for ct = 1:numel(diagResults)
                thisResult = diagResults{ct};
                if ~isempty(thisResult)
                    printLine(thisResult);
                end
            end
        end
        
        function printDiagnosticsFromEventData(runnableContent, evd)
            printHeaderAndDiagnosticResults(...
                getString(runnableContent.DiagnosticCatalog, 'TestDiagnosticHeader'), ...
                evd.TestDiagnosticResult);
            
            printHeaderAndDiagnosticResults(...
                getString(runnableContent.DiagnosticCatalog, 'FrameworkDiagnosticHeader'), ...
                evd.FrameworkDiagnosticResult);
        end
    end
end

function printLine(string)
fprintf(1, '%s\n', string);
end

function printHeaderAndDiagnosticResults(header, diagResults)
import matlab.unittest.internal.diagnostics.wrapHeader;
for ct = 1:numel(diagResults)
    thisResult = diagResults{ct};
    if ~isempty(thisResult)
        printLine('');
        printLine(wrapHeader(header));
        printLine(thisResult);
    end
end
end

% LocalWords:  TESTMETHOD mypackage TSome Substitutor teardowns lifecycle
% LocalWords:  FIXTURECLASSNAME evd Qualifiable qualifiable
