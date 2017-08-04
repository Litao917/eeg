classdef Fixture < matlab.unittest.internal.TestContent & matlab.mixin.Heterogeneous
    % Fixture - Interface for test fixtures.
    %
    %   Fixtures provide a means for configuring environment state required for
    %   tests. Classes which derive from the Fixture interface must provide a
    %   setup method which performs the changes to the environment. A fixture
    %   should restore the environment to its initial state when it is torn
    %   down. This can be done using addTeardown in the setup method or by
    %   overriding the teardown method which, by default, does nothing.
    %
    %   Subclasses can set the SetupDescription and TeardownDescription
    %   properties in their constructors to provide descriptions for the
    %   actions performed by the setup and teardown methods, respectively.
    %
    %   A class which derives from Fixture must override isCompatible if its
    %   constructor accepts any input arguments. Fixture subclasses use this
    %   method to define a notion of interchangeability. Two fixture instances
    %   of the same class are considered to be interchangeable if the
    %   isCompatible method returns true. When running multiple TestCase
    %   classes as a single suite, the Test Runner will tear down and set up
    %   shared test fixtures of the same class if isCompatible returns false
    %   (that is, the fixture will not be shared).
    %
    %   Fixture events:
    %       AssertionFailed      - Event triggered upon a failing assertion
    %       AssertionPassed      - Event triggered upon a passing assertion
    %       FatalAssertionFailed - Event triggered upon a failing fatal assertion
    %       FatalAssertionPassed - Event triggered upon a passing fatal assertion
    %       AssumptionFailed     - Event triggered upon a failing assumption
    %       AssumptionPassed     - Event triggered upon a passing assumption
    %       ExceptionThrown      - Event triggered when an exception is thrown
    %
    %   Fixture properties:
    %       SetupDescription    - Description of fixture setup actions
    %       TeardownDescription - Description of fixture teardown actions
    %
    %   Fixtures methods:
    %       Fixture - Class constructor
    %       addTeardown - Dynamically add a teardown routine
    %       setup - Set up fixture
    %       teardown - Tear down fixture
    %       isCompatible - Determine whether two fixtures are interchangeable
    %       assertFail - Produce an unconditional assertion failure
    %       assertThat - Assert that a value meets a given constraint
    %       assertTrue - Assert that a value is true
    %       assertFalse - Assert that a value is false
    %       assertEqual - Assert the equality of a value to an expected
    %       assertNotEqual - Assert a value is not equal to an expected
    %       assertSameHandle - Assert two values are handles to the same instance
    %       assertNotSameHandle - Assert a value isn't a handle to some instance
    %       assertError - Assert a function throws a specific exception
    %       assertWarning - Assert a function issues a specific warning
    %       assertWarningFree - Assert a function issues no warnings
    %       assertEmpty - Assert a value is empty
    %       assertNotEmpty - Assert a value is not empty
    %       assertSize - Assert a value has an expected size
    %       assertLength - Assert a value has an expected length
    %       assertNumElements - Assert a value has an expected element count
    %       assertGreaterThan - Assert a value is larger than some floor
    %       assertGreaterThanOrEqual - Assert a value is equal or larger than some floor
    %       assertLessThan - Assert a value is less than some ceiling
    %       assertLessThanOrEqual - Assert a value is equal or smaller than some ceiling
    %       assertReturnsTrue - Assert a function returns true when evaluated
    %       assertInstanceOf - Assert a value "isa" expected type
    %       assertClass - Assert the exact class of some value
    %       assertSubstring - Assert a string contains an expected string
    %       assertMatches - Assert a string matches a regular expression
    %       assumeFail - Produce an unconditional assumption failure
    %       assumeThat - Assume that a value meets a given constraint
    %       assumeTrue - Assume that a value is true
    %       assumeFalse - Assume that a value is false
    %       assumeEqual - Assume the equality of a value to an expected
    %       assumeNotEqual - Assume a value is not equal to an expected
    %       assumeSameHandle - Assume two values are handles to the same instance
    %       assumeNotSameHandle - Assume a value isn't a handle to some instance
    %       assumeError - Assume a function throws a specific exception
    %       assumeWarning - Assume a function issues a specific warning
    %       assumeWarningFree - Assume a function issues no warnings
    %       assumeEmpty - Assume a value is empty
    %       assumeNotEmpty - Assume a value is not empty
    %       assumeSize - Assume a value has an expected size
    %       assumeLength - Assume a value has an expected length
    %       assumeNumElements - Assume a value has an expected element count
    %       assumeGreaterThan - Assume a value is larger than some floor
    %       assumeGreaterThanOrEqual - Assume a value is equal or larger than some floor
    %       assumeLessThan - Assume a value is less than some ceiling
    %       assumeLessThanOrEqual - Assume a value is equal or smaller than some ceiling
    %       assumeReturnsTrue - Assume a function returns true when evaluated
    %       assumeInstanceOf - Assume a value "isa" expected type
    %       assumeClass - Assume the exact class of some value
    %       assumeSubstring - Assume a string contains an expected string
    %       assumeMatches - Assume a string matches a regular expression
    %       fatalAssertFail - Produce an unconditional fatal assertion failure
    %       fatalAssertThat - Fatally assert that a value meets a given constraint
    %       fatalAssertTrue - Fatally assert that a value is true
    %       fatalAssertFalse - Fatally assert that a value is false
    %       fatalAssertEqual - Fatally assert the equality of a value to an expected
    %       fatalAssertNotEqual - Fatally assert a value is not equal to an expected
    %       fatalAssertSameHandle - Fatally assert two values are handles to the same instance
    %       fatalAssertNotSameHandle - Fatally assert a value isn't a handle to some instance
    %       fatalAssertError - Fatally assert a function throws a specific exception
    %       fatalAssertWarning - Fatally assert a function issues a specific warning
    %       fatalAssertWarningFree - Fatally assert a function issues no warnings
    %       fatalAssertEmpty - Fatally assert a value is empty
    %       fatalAssertNotEmpty - Fatally assert a value is not empty
    %       fatalAssertSize - Fatally assert a value has an expected size
    %       fatalAssertLength - Fatally assert a value has an expected length
    %       fatalAssertNumElements - Fatally assert a value has an expected element count
    %       fatalAssertGreaterThan - Fatally assert a value is larger than some floor
    %       fatalAssertGreaterThanOrEqual - Fatally assert a value is equal or larger than some floor
    %       fatalAssertLessThan - Fatally assert a value is less than some ceiling
    %       fatalAssertLessThanOrEqual - Fatally assert a value is equal or smaller than some ceiling
    %       fatalAssertReturnsTrue - Fatally assert a function returns true when evaluated
    %       fatalAssertInstanceOf - Fatally assert a value "isa" expected type
    %       fatalAssertClass - Fatally assert the exact class of some value
    %       fatalAssertSubstring - Fatally assert a string contains an expected string
    %       fatalAssertMatches - Fatally assert a string matches a regular expression
    %
    %   See also
    %       matlab.unittest.TestCase/applyFixture
    %       matlab.unittest.TestCase/getSharedTestFixtures
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    properties (SetAccess=protected)
        % SetupDescription - Description of fixture setup actions
        %   The SetupDescription property is a string which describes the
        %   actions the fixture performs when its setup method is invoked.
        SetupDescription = '';
        
        % TeardownDescription - Description of fixture teardown actions
        %   The TeardownDescription property is a string which describes the
        %   actions the fixture performs when its teardown method is invoked.
        TeardownDescription = '';
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        FixtureClassName
    end
    
    properties (Access=private)
        Qualifiable
    end
    
    events (Hidden, NotifyAccess=private)
        % This event is undocumented and may change in a future release.
        
        % DiagnosticLogged - Event triggered by calls to the log method.
        %   The DiagnosticLogged event provides a means to observe and react to
        %   calls to the log method. Callback functions listening to the event
        %   receive information about the time and location of the call to the log
        %   method as well as the user-supplied diagnostic message and the level.
        %
        %   See also: matlab.unittest.fixtures.Fixture/log
        DiagnosticLogged
    end
    
    % Qualification events
    events (NotifyAccess=private)
        % AssertionPassed - Event triggered upon a passing assertion.
        %   The AssertionPassed event provides a means to observe and react
        %   to passing assertions on fixture. Callback functions listening
        %   to the event receive information about the passing
        %   qualification including the actual value, constraint applied,
        %   diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssertionPassed;
               
        % AssertionFailed - Event triggered upon a failing assertion.
        %   The AssertionFailed event provides a means to observe and react
        %   to failing assertions on fixture. Callback functions listening
        %   to the event receive information about the failing
        %   qualification including the actual value, constraint applied,
        %   diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssertionFailed;
        
        % AssumptionPassed - Event triggered upon a passing assumption.
        %   The AssumptionPassed event provides a means to observe and
        %   react to passing assumptions on fixture. Callback functions
        %   listening to the event receive information about the passing
        %   qualification including the actual value, constraint applied,
        %   diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssumptionPassed;
               
        % AssumptionFailed - Event triggered upon a failing assumption.
        %   The AssumptionFailed event provides a means to observe and
        %   react to failing assumptions on fixture. Callback functions
        %   listening to the event receive information about the failing
        %   qualification including the actual value, constraint applied,
        %   diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssumptionFailed;        
        
        % FatalAssertionPassed - Event triggered upon a passing fatal assertion.
        %   The FatalAssertionPassed event provides a means to observe and
        %   react to passing fatal assertions on fixture. Callback
        %   functions listening to the event receive information about the
        %   passing qualification including the actual value, constraint
        %   applied, diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        FatalAssertionPassed;
               
        % FatalAssertionFailed - Event triggered upon a failing fatal assertion.
        %   The FatalAssertionFailed event provides a means to observe and
        %   react to failing fatal assertions on fixture. Callback
        %   functions listening to the event receive information about the
        %   failing qualification including the actual value, constraint
        %   applied, diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        FatalAssertionFailed;        
    end
    
    
    methods (Abstract)
        % setup - Set up fixture.
        %
        %   setup(FIXTURE) is called to set up the test fixture and perform
        %   the necessary environment modifications.
        setup(fixture)
    end
    
    methods
        function fixture = Fixture
            % Fixture - Class constructor.
            %
            %   FIXTURE = Fixture constructs a fixture instance and returns it as FIXTURE.
            
            import matlab.unittest.internal.qualifications.ThrowingQualifiable;
            import matlab.unittest.internal.diagnostics.getSimpleClassName;
            
            fixture.FixtureClassName = class(fixture);
            fixtureMetaclass = metaclass(fixture);
            derivedClassConstructor = fixtureMetaclass.MethodList.findobj( ...
                'Name',getSimpleClassName(fixture.FixtureClassName));
            
            if ~isempty(derivedClassConstructor.InputNames)
                % If the derived class's constructor accepts any inputs,
                % the derived class must override isCompatible.
                
                isCompatibleMethod = fixtureMetaclass.MethodList.findobj( ...
                    'Name','isCompatible');
                
                if strcmp(isCompatibleMethod.DefiningClass.Name, 'matlab.unittest.fixtures.Fixture')
                    error(message('MATLAB:unittest:Fixture:MustOverrideIsCompatible', ...
                        fixture.FixtureClassName));
                end
            end
            
            fixture.Qualifiable = ThrowingQualifiable;
            
            % Register listeners to forward events that occur on the
            % ThrowingQualifiable to the Fixture.
            fixture.addForwardingListener('DiagnosticLogged', @fixture.forwardDiagnosticLoggedEvent);
            fixture.addForwardingListener('AssertionFailed', @fixture.forwardQualificationEvent);
            fixture.addForwardingListener('AssertionPassed', @fixture.forwardQualificationEvent);
            fixture.addForwardingListener('FatalAssertionFailed', @fixture.forwardQualificationEvent);
            fixture.addForwardingListener('FatalAssertionPassed', @fixture.forwardQualificationEvent);
            fixture.addForwardingListener('AssumptionFailed', @fixture.forwardQualificationEvent);
            fixture.addForwardingListener('AssumptionPassed', @fixture.forwardQualificationEvent);
        end
        
        function teardown(~)
            % teardown - Tear down fixture.
            %
            %   teardown(FIXTURE) is called to tear down the test fixture
            %   and restore the environment to its original state.
        end
        
        function set.SetupDescription(fixture, str)
            validateattributes(str, {'char'}, {}, '', 'SetupDescription');
            fixture.SetupDescription = str;
        end
        
        function set.TeardownDescription(fixture, str)
            validateattributes(str, {'char'}, {}, '', 'TeardownDescription');
            fixture.TeardownDescription = str;
        end
    end
    
    methods (Access=protected)
        function bool = isCompatible(~,~)
            % isCompatible - Determine whether two fixtures are interchangeable.
            %
            %   isCompatible(FIXTURE, OTHERFIXTURE) returns true if FIXTURE and
            %   OTHERFIXTURE perform the same changes to the environment. Otherwise,
            %   the method returns false. Subclasses should override this method if it
            %   is possible to configure the fixture in different ways that perform
            %   different environment changes. isCompatible should only be called with
            %   two instances that are of the same class.
            
            bool = true;
        end
        
        % Override copyElement method:
        function newCopy = copyElement(original)
            newCopy = copyElement@matlab.unittest.internal.TestContent(original);
            newCopy.Qualifiable = copy(newCopy.Qualifiable);
            
            % Register listeners to forward events that occur on the
            % ThrowingQualifiable to the Fixture.
            newCopy.addForwardingListener('DiagnosticLogged', @newCopy.forwardDiagnosticLoggedEvent);
            newCopy.addForwardingListener('AssertionFailed', @newCopy.forwardQualificationEvent);
            newCopy.addForwardingListener('AssertionPassed', @newCopy.forwardQualificationEvent);
            newCopy.addForwardingListener('FatalAssertionFailed', @newCopy.forwardQualificationEvent);
            newCopy.addForwardingListener('FatalAssertionPassed', @newCopy.forwardQualificationEvent);
            newCopy.addForwardingListener('AssumptionFailed', @newCopy.forwardQualificationEvent);
            newCopy.addForwardingListener('AssumptionPassed', @newCopy.forwardQualificationEvent);
        end
    end
    
    methods (Hidden, Sealed, Static, Access=protected)
        function instance = getDefaultScalarElement
            instance = matlab.unittest.fixtures.EmptyFixture;
        end
    end
    
    methods (Hidden)
        function applyTestCase(~,~)
            % applyTestCase - Use fixture with TestCase.
            %
            %   applyTestCase(FIXTURE, TESTCASE) is invoked before running content
            %   in TESTCASE. It provides FIXTURE the opportunity to install
            %   listeners on TESTCASE so that FIXTURE can react to failures in
            %   TESTCASE content.
        end
    end
    
    methods (Hidden, Sealed)
        function idx = getTestFixturesToSetup(active, required)
            idx = find(arrayfun(@(f)~active.containsEquivalentFixture(f), required));
        end
        
        function idx = getFirstFixtureToTeardown(active, desired)
            idx = [];
            for fixtureIdx = 1:numel(active)
                if ~desired.containsEquivalentFixture(active(fixtureIdx));
                    idx = fixtureIdx;
                    break;
                end
            end
        end
        
        function fixtures = getUniqueTestFixtures(fixtures)
            for idx1 = 1:numel(fixtures)
                for idx2 = numel(fixtures):-1:idx1+1
                    if areFixturesEquivalent(fixtures(idx1),fixtures(idx2))
                        fixtures(idx2) = [];
                    end
                end
            end
        end
        
        function bool = containsEquivalentFixture(fixtureArray, otherFixture)
            bool = false;
            for fixture = fixtureArray
                if areFixturesEquivalent(fixture, otherFixture)
                    bool = true;
                    break;
                end
            end
        end
    end
    
    methods (Hidden, Sealed, Access=?matlab.unittest.internal.TestContentDelegateSubstitutor)
        function substituteQualifiable_(fixture, newQualifiable)
            fixture.Qualifiable = newQualifiable;
        end
    end
    
    methods (Access=private)
        function addForwardingListener(fixture, eventName, callback)
            % Add a listener on the ThrowingQualifiable to forward events to the Fixture.
            fixture.Qualifiable.addlistener(eventName, ...
                @(~,evd)callback(eventName,evd));
        end
        
        function forwardDiagnosticLoggedEvent(fixture, eventName, srcEventData)
            % Forward the DiagnosticLogged event that occurs on the
            % ThrowingQualifiable to the Fixture.
            forwardedEventData = ...
                matlab.unittest.diagnostics.LoggedDiagnosticEventData.fromAnotherLoggedDiagnosticEventData(srcEventData);
            fixture.notify(eventName, forwardedEventData);
        end
        
        function forwardQualificationEvent(fixture, eventName, srcEventData)
            % Forward a Qualification event that occurs on the
            % ThrowingQualifiable to the Fixture.
            forwardedEventData = ...
                matlab.unittest.qualifications.QualificationEventData.fromAnotherQualificationEventData(srcEventData);
            fixture.notify(eventName, forwardedEventData);
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function log(fixture, varargin)
            % This method is undocumented and may change in a future release.
            
            % log - Print diagnostic information.
            %   The log method provides a means for fixtures to log information during
            %   the execution of a setup and teardown routines. Logged messages are
            %   displayed only if the framework is configured to do so, for example,
            %   through the use of a matlab.unittest.plugins.LoggingPlugin instance.
            %
            %   FIXTURE.log(DIAG) logs the supplied diagnostic DIAG which can be
            %   specified as a string, a function handle that displays a string, or an
            %   instance of a matlab.unittest.diagnostics.Diagnostic.
            %
            %   FIXTURE.log(LEVEL, DIAG) logs the diagnostic at the specified LEVEL.
            %   LEVEL can be either a numeric value (0, 1, 2, or 3) or a value from the
            %   matlab.unittest.Verbosity enumeration. When level is unspecified, the
            %   log method uses level Concise (1).
            %   
            %   See also: matlab.unittest.plugins.LoggingPlugin, matlab.unittest.Verbosity
            
            fixture.Qualifiable.log(varargin{:});
        end
    end
    
    methods (Sealed, Access=protected)
        function assertMatches(fixture, varargin)
            % assertMatches - Assert a string matches a regular expression
            %
            %   Use assertMatches inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertMatches
            
            fixture.Qualifiable.assertMatches(varargin{:});
        end
        
        function assertSubstring(fixture, varargin)
            % assertSubstring - Assert a string contains an expected string
            %
            %   Use assertSubstring inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertSubstring
            
            fixture.Qualifiable.assertSubstring(varargin{:});
        end
        
        function assertClass(fixture, varargin)
            % assertClass - Assert the exact class of some value
            %
            %   Use assertClass inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertClass
            
            fixture.Qualifiable.assertClass(varargin{:});
        end
        
        function assertInstanceOf(fixture, varargin)
            % assertInstanceOf - Assert a value "isa" expected type
            %
            %   Use assertInstanceOf inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertInstanceOf
            
            fixture.Qualifiable.assertInstanceOf(varargin{:});
        end
        
        function assertReturnsTrue(fixture, varargin)
            % assertReturnsTrue - Assert a function returns true when evaluated
            %
            %   Use assertReturnsTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertReturnsTrue
            
            fixture.Qualifiable.assertReturnsTrue(varargin{:});
        end
        
        function assertLessThanOrEqual(fixture, varargin)
            % assertLessThanOrEqual - Assert a value is equal or smaller than some ceiling
            %
            %   Use assertLessThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertLessThanOrEqual
            
            fixture.Qualifiable.assertLessThanOrEqual(varargin{:});
        end
        
        function assertLessThan(fixture, varargin)
            % assertLessThan - Assert a value is less than some ceiling
            %
            %   Use assertLessThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertLessThan
            
            fixture.Qualifiable.assertLessThan(varargin{:});
        end
        
        function assertGreaterThanOrEqual(fixture, varargin)
            % assertGreaterThanOrEqual - Assert a value is equal or larger than some floor
            %
            %   Use assertGreaterThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertGreaterThanOrEqual
            
            fixture.Qualifiable.assertGreaterThanOrEqual(varargin{:});
        end
        
        function assertGreaterThan(fixture, varargin)
            % assertGreaterThan - Assert a value is larger than some floor
            %
            %   Use assertGreaterThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertGreaterThan
            
            fixture.Qualifiable.assertGreaterThan(varargin{:});
        end
        
        function assertNumElements(fixture, varargin)
            % assertNumElements - Assert a value has an expected element count
            %
            %   Use assertNumElements inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertNumElements
            
            fixture.Qualifiable.assertNumElements(varargin{:});
        end
        
        function assertLength(fixture, varargin)
            % assertLength - Assert a value has an expected length
            %
            %   Use assertLength inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertLength
            
            fixture.Qualifiable.assertLength(varargin{:});
        end
        
        function assertSize(fixture, varargin)
            % assertSize - Assert a value has an expected size
            %
            %   Use assertSize inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertSize
            
            fixture.Qualifiable.assertSize(varargin{:});
        end
        
        function assertNotEmpty(fixture, varargin)
            % assertNotEmpty - Assert a value is not empty
            %
            %   Use assertNotEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertNotEmpty
            
            fixture.Qualifiable.assertNotEmpty(varargin{:});
        end
        
        function assertEmpty(fixture, varargin)
            % assertEmpty - Assert a value is empty
            %
            %   Use assertEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertEmpty
            
            fixture.Qualifiable.assertEmpty(varargin{:});
        end
        
        function assertWarningFree(fixture, varargin)
            % assertWarningFree - Assert a function issues no warnings
            %
            %   Use assertWarningFree inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertWarningFree
            
            fixture.Qualifiable.assertWarningFree(varargin{:});
        end
        
        function assertWarning(fixture, varargin)
            % assertWarning - Assert a function issues a specific warning
            %
            %   Use assertWarning inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertWarning
            
            fixture.Qualifiable.assertWarning(varargin{:});
        end
        
        function assertError(fixture, varargin)
            % assertError - Assert a function throws a specific exception
            %
            %   Use assertError inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertError
            
            fixture.Qualifiable.assertError(varargin{:});
        end
        
        function assertNotSameHandle(fixture, varargin)
            % assertNotSameHandle - Assert a value isn't a handle to some instance
            %
            %   Use assertNotSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertNotSameHandle
            
            fixture.Qualifiable.assertNotSameHandle(varargin{:});
        end
        
        function assertSameHandle(fixture, varargin)
            % assertSameHandle - Assert two values are handles to the same instance
            %
            %   Use assertSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertSameHandle
            
            fixture.Qualifiable.assertSameHandle(varargin{:});
        end
        
        function assertNotEqual(fixture, varargin)
            % assertNotEqual - Assert a value is not equal to an expected
            %
            %   Use assertNotEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertNotEqual
            
            fixture.Qualifiable.assertNotEqual(varargin{:});
        end
        
        function assertEqual(fixture, varargin)
            % assertEqual - Assert the equality of a value to an expected
            %
            %   Use assertEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertEqual
            
            fixture.Qualifiable.assertEqual(varargin{:});
        end
        
        function assertFalse(fixture, varargin)
            % assertFalse - Assert that a value is false
            %
            %   Use assertFalse inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertFalse
            
            fixture.Qualifiable.assertFalse(varargin{:});
        end
        
        function assertTrue(fixture, varargin)
            % assertTrue - Assert that a value is true
            %
            %   Use assertTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertTrue
            
            fixture.Qualifiable.assertTrue(varargin{:});
        end
        
        function assertThat(fixture, varargin)
            % assertThat - Assert that a value meets a given constraint
            %
            %   Use assertThat inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertThat
            
            fixture.Qualifiable.assertThat(varargin{:});
        end
        
        function assertFail(fixture, varargin)
            % assertFail - Produce an unconditional assertion failure
            %
            %   Use assertFail inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assertable/assertFail
            
            fixture.Qualifiable.assertFail(varargin{:});
        end
        
        function assumeMatches(fixture, varargin)
            % assumeMatches - Assume a string matches a regular expression
            %
            %   Use assumeMatches inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeMatches
            
            fixture.Qualifiable.assumeMatches(varargin{:});
        end
        
        function assumeSubstring(fixture, varargin)
            % assumeSubstring - Assume a string contains an expected string
            %
            %   Use assumeSubstring inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeSubstring
            
            fixture.Qualifiable.assumeSubstring(varargin{:});
        end
        
        function assumeClass(fixture, varargin)
            % assumeClass - Assume the exact class of some value
            %
            %   Use assumeClass inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeClass
            
            fixture.Qualifiable.assumeClass(varargin{:});
        end
        
        function assumeInstanceOf(fixture, varargin)
            % assumeInstanceOf - Assume a value "isa" expected type
            %
            %   Use assumeInstanceOf inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeInstanceOf
            
            fixture.Qualifiable.assumeInstanceOf(varargin{:});
        end
        
        function assumeReturnsTrue(fixture, varargin)
            % assumeReturnsTrue - Assume a function returns true when evaluated
            %
            %   Use assumeReturnsTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeReturnsTrue
            
            fixture.Qualifiable.assumeReturnsTrue(varargin{:});
        end
        
        function assumeLessThanOrEqual(fixture, varargin)
            % assumeLessThanOrEqual - Assume a value is equal or smaller than some ceiling
            %
            %   Use assumeLessThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeLessThanOrEqual
            
            fixture.Qualifiable.assumeLessThanOrEqual(varargin{:});
        end
        
        function assumeLessThan(fixture, varargin)
            % assumeLessThan - Assume a value is less than some ceiling
            %
            %   Use assumeLessThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeLessThan
            
            fixture.Qualifiable.assumeLessThan(varargin{:});
        end
        
        function assumeGreaterThanOrEqual(fixture, varargin)
            % assumeGreaterThanOrEqual - Assume a value is equal or larger than some floor
            %
            %   Use assumeGreaterThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeGreaterThanOrEqual
            
            fixture.Qualifiable.assumeGreaterThanOrEqual(varargin{:});
        end
        
        function assumeGreaterThan(fixture, varargin)
            % assumeGreaterThan - Assume a value is larger than some floor
            %
            %   Use assumeGreaterThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeGreaterThan
            
            fixture.Qualifiable.assumeGreaterThan(varargin{:});
        end
        
        function assumeNumElements(fixture, varargin)
            % assumeNumElements - Assume a value has an expected element count
            %
            %   Use assumeNumElements inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeNumElements
            
            fixture.Qualifiable.assumeNumElements(varargin{:});
        end
        
        function assumeLength(fixture, varargin)
            % assumeLength - Assume a value has an expected length
            %
            %   Use assumeLength inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeLength
            
            fixture.Qualifiable.assumeLength(varargin{:});
        end
        
        function assumeSize(fixture, varargin)
            % assumeSize - Assume a value has an expected size
            %
            %   Use assumeSize inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeSize
            
            fixture.Qualifiable.assumeSize(varargin{:});
        end
        
        function assumeNotEmpty(fixture, varargin)
            % assumeNotEmpty - Assume a value is not empty
            %
            %   Use assumeNotEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeNotEmpty
            
            fixture.Qualifiable.assumeNotEmpty(varargin{:});
        end
        
        function assumeEmpty(fixture, varargin)
            % assumeEmpty - Assume a value is empty
            %
            %   Use assumeEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeEmpty
            
            fixture.Qualifiable.assumeEmpty(varargin{:});
        end
        
        function assumeWarningFree(fixture, varargin)
            % assumeWarningFree - Assume a function issues no warnings
            %
            %   Use assumeWarningFree inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeWarningFree
            
            fixture.Qualifiable.assumeWarningFree(varargin{:});
        end
        
        function assumeWarning(fixture, varargin)
            % assumeWarning - Assume a function issues a specific warning
            %
            %   Use assumeWarning inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeWarning
            
            fixture.Qualifiable.assumeWarning(varargin{:});
        end
        
        function assumeError(fixture, varargin)
            % assumeError - Assume a function throws a specific exception
            %
            %   Use assumeError inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeError
            
            fixture.Qualifiable.assumeError(varargin{:});
        end
        
        function assumeNotSameHandle(fixture, varargin)
            % assumeNotSameHandle - Assume a value isn't a handle to some instance
            %
            %   Use assumeNotSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeNotSameHandle
            
            fixture.Qualifiable.assumeNotSameHandle(varargin{:});
        end
        
        function assumeSameHandle(fixture, varargin)
            % assumeSameHandle - Assume two values are handles to the same instance
            %
            %   Use assumeSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeSameHandle
            
            fixture.Qualifiable.assumeSameHandle(varargin{:});
        end
        
        function assumeNotEqual(fixture, varargin)
            % assumeNotEqual - Assume a value is not equal to an expected
            %
            %   Use assumeNotEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeNotEqual
            
            fixture.Qualifiable.assumeNotEqual(varargin{:});
        end
        
        function assumeEqual(fixture, varargin)
            % assumeEqual - Assume the equality of a value to an expected
            %
            %   Use assumeEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeEqual
            
            fixture.Qualifiable.assumeEqual(varargin{:});
        end
        
        function assumeFalse(fixture, varargin)
            % assumeFalse - Assume that a value is false
            %
            %   Use assumeFalse inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeFalse
            
            fixture.Qualifiable.assumeFalse(varargin{:});
        end
        
        function assumeTrue(fixture, varargin)
            % assumeTrue - Assume that a value is true
            %
            %   Use assumeTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeTrue
            
            fixture.Qualifiable.assumeTrue(varargin{:});
        end
        
        function assumeThat(fixture, varargin)
            % assumeThat - Assume that a value meets a given constraint
            %
            %   Use assumeThat inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeThat
            
            fixture.Qualifiable.assumeThat(varargin{:});
        end
        
        function assumeFail(fixture, varargin)
            % assumeFail - Produce an unconditional assumption failure
            %
            %   Use assumeFail inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.Assumable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.Assumable/assumeFail
            
            fixture.Qualifiable.assumeFail(varargin{:});
        end
        
        function fatalAssertMatches(fixture, varargin)
            % fatalAssertMatches - Fatally assert a string matches a regular expression
            %
            %   Use fatalAssertMatches inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertMatches
            
            fixture.Qualifiable.fatalAssertMatches(varargin{:});
        end
        
        function fatalAssertSubstring(fixture, varargin)
            % fatalAssertSubstring - Fatally assert a string contains an expected string
            %
            %   Use fatalAssertSubstring inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertSubstring
            
            fixture.Qualifiable.fatalAssertSubstring(varargin{:});
        end
        
        function fatalAssertClass(fixture, varargin)
            % fatalAssertClass - Fatally assert the exact class of some value
            %
            %   Use fatalAssertClass inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertClass
            
            fixture.Qualifiable.fatalAssertClass(varargin{:});
        end
        
        function fatalAssertInstanceOf(fixture, varargin)
            % fatalAssertInstanceOf - Fatally assert a value "isa" expected type
            %
            %   Use fatalAssertInstanceOf inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertInstanceOf
            
            fixture.Qualifiable.fatalAssertInstanceOf(varargin{:});
        end
        
        function fatalAssertReturnsTrue(fixture, varargin)
            % fatalAssertReturnsTrue - Fatally assert a function returns true when evaluated
            %
            %   Use fatalAssertReturnsTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertReturnsTrue
            
            fixture.Qualifiable.fatalAssertReturnsTrue(varargin{:});
        end
        
        function fatalAssertLessThanOrEqual(fixture, varargin)
            % fatalAssertLessThanOrEqual - Fatally assert a value is equal or smaller than some ceiling
            %
            %   Use fatalAssertLessThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertLessThanOrEqual
            
            fixture.Qualifiable.fatalAssertLessThanOrEqual(varargin{:});
        end
        
        function fatalAssertLessThan(fixture, varargin)
            % fatalAssertLessThan - Fatally assert a value is less than some ceiling
            %
            %   Use fatalAssertLessThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertLessThan
            
            fixture.Qualifiable.fatalAssertLessThan(varargin{:});
        end
        
        function fatalAssertGreaterThanOrEqual(fixture, varargin)
            % fatalAssertGreaterThanOrEqual - Fatally assert a value is equal or larger than some floor
            %
            %   Use fatalAssertGreaterThanOrEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertGreaterThanOrEqual
            
            fixture.Qualifiable.fatalAssertGreaterThanOrEqual(varargin{:});
        end
        
        function fatalAssertGreaterThan(fixture, varargin)
            % fatalAssertGreaterThan - Fatally assert a value is larger than some floor
            %
            %   Use fatalAssertGreaterThan inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertGreaterThan
            
            fixture.Qualifiable.fatalAssertGreaterThan(varargin{:});
        end
        
        function fatalAssertNumElements(fixture, varargin)
            % fatalAssertNumElements - Fatally assert a value has an expected element count
            %
            %   Use fatalAssertNumElements inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertNumElements
            
            fixture.Qualifiable.fatalAssertNumElements(varargin{:});
        end
        
        function fatalAssertLength(fixture, varargin)
            % fatalAssertLength - Fatally assert a value has an expected length
            %
            %   Use fatalAssertLength inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertLength
            
            fixture.Qualifiable.fatalAssertLength(varargin{:});
        end
        
        function fatalAssertSize(fixture, varargin)
            % fatalAssertSize - Fatally assert a value has an expected size
            %
            %   Use fatalAssertSize inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertSize
            
            fixture.Qualifiable.fatalAssertSize(varargin{:});
        end
        
        function fatalAssertNotEmpty(fixture, varargin)
            % fatalAssertNotEmpty - Fatally assert a value is not empty
            %
            %   Use fatalAssertNotEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertNotEmpty
            
            fixture.Qualifiable.fatalAssertNotEmpty(varargin{:});
        end
        
        function fatalAssertEmpty(fixture, varargin)
            % fatalAssertEmpty - Fatally assert a value is empty
            %
            %   Use fatalAssertEmpty inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertEmpty
            
            fixture.Qualifiable.fatalAssertEmpty(varargin{:});
        end
        
        function fatalAssertWarningFree(fixture, varargin)
            % fatalAssertWarningFree - Fatally assert a function issues no warnings
            %
            %   Use fatalAssertWarningFree inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertWarningFree
            
            fixture.Qualifiable.fatalAssertWarningFree(varargin{:});
        end
        
        function fatalAssertWarning(fixture, varargin)
            % fatalAssertWarning - Fatally assert a function issues a specific warning
            %
            %   Use fatalAssertWarning inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertWarning
            
            fixture.Qualifiable.fatalAssertWarning(varargin{:});
        end
        
        function fatalAssertError(fixture, varargin)
            % fatalAssertError - Fatally assert a function throws a specific exception
            %
            %   Use fatalAssertError inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertError
            
            fixture.Qualifiable.fatalAssertError(varargin{:});
        end
        
        function fatalAssertNotSameHandle(fixture, varargin)
            % fatalAssertNotSameHandle - Fatally assert a value isn't a handle to some instance
            %
            %   Use fatalAssertNotSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertNotSameHandle
            
            fixture.Qualifiable.fatalAssertNotSameHandle(varargin{:});
        end
        
        function fatalAssertSameHandle(fixture, varargin)
            % fatalAssertSameHandle - Fatally assert two values are handles to the same instance
            %
            %   Use fatalAssertSameHandle inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertSameHandle
            
            fixture.Qualifiable.fatalAssertSameHandle(varargin{:});
        end
        
        function fatalAssertNotEqual(fixture, varargin)
            % fatalAssertNotEqual - Fatally assert a value is not equal to an expected
            %
            %   Use fatalAssertNotEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertNotEqual
            
            fixture.Qualifiable.fatalAssertNotEqual(varargin{:});
        end
        
        function fatalAssertEqual(fixture, varargin)
            % fatalAssertEqual - Fatally assert the equality of a value to an expected
            %
            %   Use fatalAssertEqual inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertEqual
            
            fixture.Qualifiable.fatalAssertEqual(varargin{:});
        end
        
        function fatalAssertFalse(fixture, varargin)
            % fatalAssertFalse - Fatally assert that a value is false
            %
            %   Use fatalAssertFalse inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertFalse
            
            fixture.Qualifiable.fatalAssertFalse(varargin{:});
        end
        
        function fatalAssertTrue(fixture, varargin)
            % fatalAssertTrue - Fatally assert that a value is true
            %
            %   Use fatalAssertTrue inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertTrue
            
            fixture.Qualifiable.fatalAssertTrue(varargin{:});
        end
        
        function fatalAssertThat(fixture, varargin)
            % fatalAssertThat - Fatally assert that a value meets a given constraint
            %
            %   Use fatalAssertThat inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertThat
            
            fixture.Qualifiable.fatalAssertThat(varargin{:});
        end
        
        function fatalAssertFail(fixture, varargin)
            % fatalAssertFail - Produce an unconditional fatal assertion failure
            %
            %   Use fatalAssertFail inside the fixture setup and teardown methods. Refer
            %   to matlab.unittest.qualifications.FatalAssertable for more information and
            %   examples on using this method.
            %
            % See also: matlab.unittest.qualifications.FatalAssertable/fatalAssertFail
            
            fixture.Qualifiable.fatalAssertFail(varargin{:});
        end
    end
end

function bool = areFixturesEquivalent(fixture1, fixture2)
bool = strcmp(fixture1.FixtureClassName, fixture2.FixtureClassName) && ...
    isCompatible(fixture1, fixture2);
end

% LocalWords:  Qualifiable Substitutor OTHERFIXTURE evd
