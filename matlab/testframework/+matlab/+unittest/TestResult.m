classdef TestResult < matlab.mixin.CustomDisplay
    % TestResult - Result of a running a test suite
    %
    %   The matlab.unittest.TestResult class holds the information describing
    %   the result of running a test suite using the matlab.unittest.TestRunner.
    %   It contains information describing whether the test passed, failed,
    %   or ran to completion as well as the duration of the tests.
    %
    %   TestResult arrays are created and returned by the test runner, and are
    %   of the same size as the suite which was run.
    %
    %   TestResult properties:
    %       Name       - The name of the TestSuite for this result
    %       Passed     - Logical value showing if the test passed
    %       Failed     - Logical value showing if the test failed
    %       Incomplete - Logical value showing if test did not run to completion
    %       Duration   - Time elapsed running test
    %
    %   Examples:
    %
    %       >> import matlab.unittest.TestSuite;
    %       >> % Result display method provides a summary of the results
    %       >> suite = TestSuite.fromClass(?SomeTestClass)
    %       >> results = run(suite)
    %   
    %       results = 
    %
    %         1x16 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %
    %         Totals:
    %           12 Passed, 4 Failed, 0 Incomplete.
    %           5.5091 seconds testing time.
    %       >> 
    %       >> % Re-run only the failed tests
    %       >> failedTests = suite([results.Failed]);
    %       >> failedResults = run(failedTests)
    %   
    %       failedResults = 
    %
    %         1x4 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %
    %         Test Suite Summary:
    %           0 Passed, 4 Failed, 0 Incomplete.
    %           1.2894 seconds testing time.
    %
    %       >> % Make the fix
    %       >> newResults = run(failedTests)
    %       
    %       newResults = 
    %
    %         1x4 TestResult array with properties:
    %
    %           Name
    %           Passed
    %           Failed
    %           Incomplete
    %           Duration
    %
    %         Test Suite Summary:
    %           4 Passed, 0 Failed, 0 Incomplete.
    %           1.1607 seconds testing time.
    %
    %   See also: TestSuite, TestRunner
    % 
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    properties (SetAccess={?matlab.unittest.TestResult, ?matlab.unittest.TestRunner})
        % Name - The name of the TestSuite for this result
        %
        %   The Name property is a string that holds the name of the test
        %   corresponding to this result.
        Name = '';
    end
    
    properties (Dependent)
        % Passed - Logical value showing if the test passed
        %
        %   When the Passed property is TRUE, then the test completed as expected
        %   without any failure. When it is FALSE, then the test did not run to
        %   completion and/or encountered a failure condition.
        %
        Passed
        
        % Failed - Logical value showing if the test failed
        %
        %   A TRUE Failed property indicates some form of test failure. When it is
        %   FALSE, then no failing conditions were encountered. A failing result
        %   can occur with a failure condition in either a test or when setting
        %   up and tearing down test fixtures. Failures can occur due to the
        %   following:
        %       - Verification failures
        %       - Assertion failures
        %       - Uncaught MExceptions
        %
        %   Fatal assertions are also failing conditions, but in the
        %   event of a fatal assertion failure the entire framework aborts and a
        %   TestResult is never produced.
        %
        Failed
        
        % Incomplete - Logical value showing if test did not run to completion
        %
        %   A TRUE Incomplete property indicates when a test did not run to
        %   completion. When it is FALSE, then no conditions were encountered that
        %   prevented the test from completing. In other words, when FALSE there
        %   were no stack disruptions out of the running test content. An
        %   incomplete result can occur with a stack disruption in either a test or
        %   when setting up and tearing down test fixtures. Incomplete tests can
        %   occur due to the following:
        %       - Assumption failures
        %       - Assertion failures
        %       - Uncaught MExceptions
        %
        %   Fatal assertions are also conditions that prevent the completion of
        %   tests, but in the event of a fatal assertion failure the entire
        %   framework aborts and a TestResult is never produced.
        %
        Incomplete
    end
    
    properties (SetAccess={?matlab.unittest.TestRunner})
        % Duration - Time elapsed running test
        %
        %   The Duration property indicates the amount of time taken to run a
        %   particular test, including the time taken setting up and tearing
        %   down any test fixtures.
        %
        %   Fixture setup time is accounted for in duration of the first
        %   test suite array element that uses the fixture. Fixture
        %   teardown time is accounted for in the duration of the last test
        %   suite array element that uses the fixture.
        %
        %   The total runtime for a suite of tests will exceed the sum of the
        %   durations for all the elements of the suite because the Duration
        %   property does not include all the overhead of the TestRunner
        %   nor any of the time consumed by test runner plugins.
        %
        Duration = 0;
    end
    
    properties (Hidden, SetAccess={?matlab.unittest.TestResult, ?matlab.unittest.TestRunner})
        Started = false;
        VerificationFailed = false;
        AssumptionFailed = false;
        AssertionFailed = false;
        Errored = false;
    end
    
    properties (Hidden, Dependent)
        Completed
    end
    
    methods(Hidden)
        function result = TestResult
        end
    end
    
    methods
        function result = set.Name(result, name)
            validateattributes(name, {'char'},{},'', 'Name');
            result.Name = name;
        end
        
        function passed = get.Passed(result)
            passed = ...
                result.Completed && ...
                ~result.Failed;
        end
        
        function failed = get.Failed(result)
            failed = ...
                result.VerificationFailed || ...
                result.AssertionFailed || ...
                result.Errored;
        end
        
        function incomplete = get.Incomplete(result)
            incomplete = ...
                result.AssumptionFailed || ...
                result.AssertionFailed || ...
                result.Errored;
        end
        
        function completed = get.Completed(result)
            completed = ...
                result.Started && ...
                ~result.Incomplete;
        end
    end
    
    methods(Hidden, Access=protected)
        function footerStr = getFooter(result)
            % getFooter - Override of the matlab.mixin.CustomDisplay hook method
            %   Displays a summary of the test results.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            totals = getString(message('MATLAB:unittest:TestResult:Totals'));
            
            passedFailedIncomplete = ...
                getString(message('MATLAB:unittest:TestResult:PassedFailedIncomplete', ...
                nnz([result.Passed]), ...
                nnz([result.Failed]), ...
                nnz([result.Incomplete])));
            
            duration = getString(message('MATLAB:unittest:TestResult:Duration', ...
                num2str(sum([result.Duration]))));
            
            indention = '   ';
            footerStr = sprintf('%s\n%s\n%s\n', totals, ...
                indent(passedFailedIncomplete, indention), ...
                indent(duration, indention));
        end
    end
end