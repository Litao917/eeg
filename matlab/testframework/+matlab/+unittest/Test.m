classdef Test < matlab.unittest.TestSuite
    % Test - Specification of a single Test method
    %
    %   The matlab.unittest.Test class holds the information needed for the
    %   TestRunner to be able to run a single Test method of a TestCase
    %   class. A scalar Test instance is the fundamental element contained
    %   in TestSuite arrays. A simple array of Test instances is a commonly
    %   used form of a TestSuite.
    %
    %   Test properties:
    %       Name               - Name of the Test element
    %       Parameterization   - Parameters for this Test element
    %       SharedTestFixtures - Fixtures for this Test element
    %
    %   Examples:
    %
    %       import matlab.unittest.TestSuite;
    %
    %       % Create a suite of Test instances comprised of all test methods in
    %       % the class.
    %       suite = TestSuite.fromClass(?SomeTestClass);
    %       result = run(suite)
    %
    %       % Create and run a single test method
    %       run(TestSuite.fromMethod(?SomeTestClass, 'testMethod'))
    %
    %   See also: TestSuite, TestRunner
    
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    properties(Dependent, SetAccess=immutable)
        % Name - Name of the Test element
        %
        %   The Name property is a string which identifies the Test method to be
        %   run for the instance. It includes the name of the test method or function
        %   the instance applies to as well as its parent.
        Name
    end
    
    properties (SetAccess=private)
        % Parameterization - Parameters for this Test element
        %
        %   The Parameterization property holds a row vector of
        %   matlab.unittest.parameters.Parameter objects that represent all the
        %   parameterized data needed for the TestRunner to run the Test method,
        %   including any parameterized TestClassSetup and TestMethodSetup methods.
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
    end
    
    properties(Hidden, Dependent, SetAccess=immutable)
        % TestCase - A matlab.unittest.TestCase instance
        %   When querying this property, the TestCase class definition must be
        %   on the path to ensure predictable behavior.
        TestCase
        
        % TestClass - Test meta.class
        %
        %   The meta.class instance which describes the test class
        %   corresponding to the TestCase instance to be created for this Test.
        %   The meta class must describe a class that derives from TestCase.
        %   When querying this property, the TestCase class definition must be
        %   on the path to ensure predictable behavior.
        %
        TestClass
        
        % TestParentName - Name of the test parent 
        %
        %   The name of the test class corresponding to the TestCase
        %   instance to be created for this Test. The name describes the
        %   file which contains the test.
        TestParentName
        
        % SharedTestClassName - Name of the shared test class
        %
        %   The name of the test class that groups tests that share the
        %   same set of class setup parameters   
        SharedTestClassName

        % TestMethod - Test meta.method
        %
        %   The meta.method instance which describes the test method which will be
        %   run for this Test. The meta method must describe a method whose Test
        %   attribute is true. When querying this property, the TestCase
        %   class definition must be on the path to ensure predictable behavior.
        %
        TestMethod
        
        % TestName - Name of the test method in the test class
        %
        %   The name of the test method which will be run for this Test.
        TestName
        
        % BaseFolder - Name of the folder that holds the test content
        %
        %   The name of the folder that holds the class or function that defines
        %   the test content. For test classes in packages, the BaseFolder is the
        %   parent of the top-level package folder.
        BaseFolder
    end
    
    properties(GetAccess=private, SetAccess=private)
        TestCaseProvider
    end
    
    properties(SetAccess=private)
        % SharedTestFixtures - Fixtures for this Test element
        %
        %   The SharedTestFixtures property holds a row vector of
        %   matlab.unittest.fixture.Fixture objects that represent all of the
        %   fixtures required for the Test element.
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
    end
    
    properties (Hidden, SetAccess=private)
        InternalSharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
    end
    
    methods(Hidden, Static)
        function test = fromName(name)
            import matlab.unittest.internal.testNameParser;
            import matlab.unittest.internal.isFunctionalTestCase;
            import matlab.unittest.selectors.HasName;
            import matlab.unittest.internal.TestCaseClassProvider;
            import matlab.unittest.parameters.ClassSetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            import matlab.unittest.parameters.TestParameter;
            
            % Parse the Name string into its parent name, test name, and
            % parameter information
            [parentName, testName, parameters] = testNameParser(name);
            
            % Determine and validate the TestClass or Function
            testClass = meta.class.fromName(parentName);
            if isempty(testClass)
                if isFunctionalTestCase(which(parentName))
                    test = feval(parentName);
                    test = test.selectIf(HasName(name));
                    if isempty(test)
                        error(message('MATLAB:unittest:TestSuite:InvalidTestFunction', ...
                            parentName, testName));
                    end
                    return;
                else
                    error(message('MATLAB:unittest:TestSuite:InvalidClassOrFunction', ...
                        parentName));
                end
            else
                [status, msg] = validateClass(testClass);
                if ~status
                    throwAsCaller(MException(msg));
                end
            end
            
            % Determine and validate the TestMethod
            [status, msg, method] = convertMethodNameToMetaMethod(testClass, testName);
            if ~status
                throwAsCaller(MException(msg));
            end
            if ~method.Test
                error(message('MATLAB:unittest:Test:TestMethodAttributeNeeded'));
            end
            
            % Determine and validate parameters
            classSetupParameters = constructParameters(parameters.ClassSetup, ...
                ClassSetupParameter.getAllParameterProperties(testClass), name, 'ClassSetup', ...
                @(propName,name)ClassSetupParameter.fromName(testClass, propName, name));
            
            methodSetupParameters = constructParameters(parameters.MethodSetup, ...
                MethodSetupParameter.getAllParameterProperties(testClass), name, 'MethodSetup', ...
                @(propName,name)MethodSetupParameter.fromName(testClass, propName, name));
            
            testParameters = constructParameters(parameters.TestMethod, ...
                TestParameter.getAllParameterProperties(testClass, testName), name, 'Test', ...
                @(propName,name)TestParameter.fromName(testClass, propName, name));
            
            % Construct the suite element
            provider = TestCaseClassProvider(testClass, method);
            fixtures = determineSharedTestFixtures(testClass);
            parameters = [classSetupParameters, methodSetupParameters, testParameters];
            test = matlab.unittest.Test(provider, fixtures, parameters);
        end
        
        function test = fromMethod(testClass, method, selector)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            [status, msg] = validateClass(testClass);
            if ~status
                throwAsCaller(MException(msg));
            end
                        
            if ischar(method)
                [status, msg, method] = convertMethodNameToMetaMethod(testClass, method);
                if ~status
                    throwAsCaller(MException(msg));
                end
            else
                validateattributes(method, {'matlab.unittest.meta.method'}, {'nonempty'}, '', 'method');
            end
            
            if ~all([method.Test])
                error(message('MATLAB:unittest:Test:TestMethodAttributeNeeded'));
            end
            
            test = buildSuite(@(method)TestCaseClassProvider(testClass, method), ...
                testClass, method, selector);
        end
        
        function test = fromClass(testClass, selector)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            [status, msg] = validateClass(testClass);
            if ~status
                throwAsCaller(MException(msg));
            end
            
            methods = rot90(testClass.MethodList.findobj('Test',true), 3);
            
            test = buildSuite(@(method)TestCaseClassProvider(testClass, method), ...
                testClass, methods, selector);
        end
        
        function test = fromTestCase(testCase, methods)
            import matlab.unittest.internal.TestCaseInstanceProvider;
            import matlab.unittest.internal.selectors.NeverFilterSelector;
            
            testClass = metaclass(testCase);
            
            if nargin > 1
                validateattributes(methods, ...
                    {'matlab.unittest.meta.method', 'char'}, {'nonempty'}, '', 'testMethod');
                
                if ischar(methods)
                    [status, msg, methods] = convertMethodNameToMetaMethod(testClass, methods);
                    if ~status
                        throwAsCaller(MException(msg));
                    end
                end
            else
                methods = rot90(testClass.MethodList.findobj('Test',true), 3);
            end
            
            % No selection capability with fromTestCase
            selector = NeverFilterSelector;
            
            test = buildSuite(@(method)TestCaseInstanceProvider(testCase, method), ...
                testClass, methods, selector);
        end
        
        function test = fromFunctions(fcns, varargin)
            import matlab.unittest.Test;
            import matlab.unittest.internal.FunctionTestCaseProvider;
            
            test = Test.fromProvider(FunctionTestCaseProvider(fcns, varargin{:}));
        end
        
        function test = fromProvider(provider)
            
            test = repmat(matlab.unittest.Test, size(provider));
            for idx = 1:numel(provider)
                test(idx) = matlab.unittest.Test(provider(idx));
            end
        end
        
    end
    
    methods(Hidden)
        function test = addFixture(test, fixture)
            validateattributes(fixture, {'matlab.unittest.fixtures.Fixture'}, {'scalar'}, '', 'fixture');
            
            for idx = 1:numel(test)
                % Don't add another instance of the same fixture
                existingFixtures = [test(idx).InternalSharedTestFixtures, test(idx).SharedTestFixtures];
                if ~existingFixtures.containsEquivalentFixture(fixture)
                    test(idx).InternalSharedTestFixtures = [test(idx).InternalSharedTestFixtures, fixture];
                end
            end
        end
    end
    
    methods(Access=private)
        function test = Test(testCaseProvider, sharedTestFixtures, parameters)
            if nargin > 0
                test.TestCaseProvider = testCaseProvider;
            end
            if nargin > 1
                test.SharedTestFixtures = sharedTestFixtures;
            end
            if nargin > 2
                test.Parameterization = parameters;
            end
        end
    end
    
    methods
        
        function name = get.Name(test)
            classSetupParams = test.Parameterization.filterByClass( ...
                'matlab.unittest.parameters.ClassSetupParameter');
            methodSetupParams = test.Parameterization.filterByClass( ...
                'matlab.unittest.parameters.MethodSetupParameter');
            testParams = test.Parameterization.filterByClass( ...
                'matlab.unittest.parameters.TestParameter');
            
            name = getTestName(classSetupParams, methodSetupParams, testParams, ...
                test.TestParentName, test.TestName);
        end
        
        function testClass = get.TestClass(test)
            testClass = test.TestCaseProvider.TestClass;
        end
        function testMethod = get.TestParentName(test)
            testMethod = test.TestCaseProvider.TestParentName;
        end
        function sharedTestClassName = get.SharedTestClassName(test)
            classSetupParams = test.Parameterization.filterByClass( ...
                'matlab.unittest.parameters.ClassSetupParameter');    
            classSetupParamsStr = getParameterNameString(classSetupParams, '[', ']'); 
            sharedTestClassName = [test.TestParentName classSetupParamsStr];
        end        
        function testMethod = get.TestMethod(test)
            testMethod = test.TestCaseProvider.TestMethod;
        end
        function testMethod = get.TestName(test)
            testMethod = test.TestCaseProvider.TestName;
        end
        
        function testCase = get.TestCase(test)
            testCase = test.TestCaseProvider.TestCase;
        end
        
        function folder = get.BaseFolder(test)
            % If a PathFixture is installed, its folder is the BaseFolder
            pathFixture = findFixture(test.InternalSharedTestFixtures, ...
                'matlab.unittest.fixtures.PathFixture');
            if ~isempty(pathFixture)
                folder = pathFixture.Folder;
                return;
            end
            
            folder = getBaseFolder(test.TestParentName);
        end
    end

    methods(Hidden)
        function testCase = createTestCaseFromClassPrototype(test, classTestCase)
            testCase = test.TestCaseProvider.createTestCaseFromClassPrototype(classTestCase);
        end
    end
    
    methods (Hidden)
        function testStruct = saveobj(test)
            testStruct.V3.Parameterization = test.Parameterization;
            testStruct.V3.TestCaseProvider = test.TestCaseProvider;
            testStruct.V3.SharedTestFixtures = test.SharedTestFixtures;
            testStruct.V3.InternalSharedTestFixtures = test.InternalSharedTestFixtures;
        end
    end
    
    methods (Hidden, Static)
        function test = loadobj(testStruct)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            % Construct a new Test and assign properties.
            test = matlab.unittest.Test;
            
            if isfield(testStruct, 'V3')
                test.Parameterization = testStruct.V3.Parameterization;
                test.TestCaseProvider = testStruct.V3.TestCaseProvider;
                test.SharedTestFixtures = testStruct.V3.SharedTestFixtures;
                test.InternalSharedTestFixtures = testStruct.V3.InternalSharedTestFixtures;
            elseif isfield(testStruct, 'V2')
                % Parameterized tests are not supported prior to R2014a (V3)
                test.TestCaseProvider = testStruct.V2.TestCaseProvider;
                test.SharedTestFixtures = testStruct.V2.SharedTestFixtures;
                test.InternalSharedTestFixtures = testStruct.V2.InternalSharedTestFixtures;
            else
                % Convert the shared test fixtures from R2013a style.
                test.InternalSharedTestFixtures = fixtureConverter(testStruct.SharedTestFixtures);
                
                restore = matlab.unittest.internal.Teardownable;
                
                % Set up Path and CurrentFolder fixtures.
                pathFixture = findFixture(test.InternalSharedTestFixtures, ...
                    'matlab.unittest.fixtures.PathFixture');
                if ~isempty(pathFixture)
                    restore.addTeardown(@path, addpath(pathFixture.Folder));
                end
                
                cdFixture = findFixture(test.InternalSharedTestFixtures, ...
                    'matlab.unittest.fixtures.CurrentFolderFixture');
                if ~isempty(cdFixture)
                    restore.addTeardown(@cd, cd(cdFixture.Folder));
                end
                
                % In R2013a, TestCaseClassProvider is the only provider that
                % could have been be serialized. Reconstruct a new one from
                % the class and method names.
                testClass = meta.class.fromName(testStruct.TestClassName);
                testMethod = testClass.MethodList.findobj('Name',testStruct.TestMethodName);
                test.TestCaseProvider = TestCaseClassProvider(testClass, testMethod);
            end
        end
    end
end


function [status, msg] = validateClass(testClass)
status = false;

if isempty(testClass)
    msg = message('MATLAB:unittest:TestSuite:InvalidClass');
    return;
end
if ~isscalar(testClass)
    msg = message('MATLAB:unittest:TestSuite:NonscalarClass');
    return;
end
if ~(metaclass(testClass) <= ?matlab.unittest.meta.class)
    msg = message('MATLAB:unittest:TestSuite:NonTestCase');
    return;
end
if testClass.Abstract
    msg = message('MATLAB:unittest:TestSuite:AbstractTestCase', testClass.Name);
    return;
end

status = true;
msg = message.empty;
end

function [status, msg, metaMethod] = convertMethodNameToMetaMethod(testClass, methodName)
status = false;

metaMethod = findobj(testClass.MethodList, 'Name', methodName);
if isempty(metaMethod)
    msg = message('MATLAB:unittest:TestSuite:InvalidMethodName', methodName, testClass.Name);
    metaMethod = [];
    return;
end

status = true;
msg = message.empty;
end

function test = buildSuite(createProvider, testClass, methods, selector)
import matlab.unittest.internal.selectors.SelectionAttribute;
import matlab.unittest.internal.selectors.BaseFolderAttribute;
import matlab.unittest.internal.selectors.SharedTestFixtureAttribute;
import matlab.unittest.internal.selectors.ParameterAttribute;
import matlab.unittest.internal.selectors.NameAttribute;
import matlab.unittest.parameters.ClassSetupParameter;
import matlab.unittest.parameters.MethodSetupParameter;
import matlab.unittest.parameters.TestParameter;

% Filter on base folder
folderAttribute = SelectionAttribute.empty;
if selector.uses(?matlab.unittest.internal.selectors.BaseFolderAttribute);
    folderAttribute = BaseFolderAttribute(getBaseFolder(testClass.Name));
    
    % Check for possible early return if the selector rejects the folder
    if ~selector.select(folderAttribute)
        test = matlab.unittest.Test.empty(1,0);
        return;
    end
end

% Filter on shared test fixtures
sharedTestFixtures = determineSharedTestFixtures(testClass);
fixtureAttribute = SelectionAttribute.empty;
if selector.uses(?matlab.unittest.internal.selectors.SharedTestFixtureAttribute)
    fixtureAttribute = SharedTestFixtureAttribute(sharedTestFixtures);
    
    % Check for possible early return if the selector rejects the fixtures
    if ~selector.select(fixtureAttribute)
        test = matlab.unittest.Test.empty(1,0);
        return;
    end
end

usesParameter = selector.uses(?matlab.unittest.internal.selectors.ParameterAttribute);
usesName = selector.uses(?matlab.unittest.internal.selectors.NameAttribute);

% Determine parameters for the test class
classSetupParameters = ClassSetupParameter.getParameters(testClass);
methodSetupParameters = MethodSetupParameter.getParameters(testClass);
testParameterMap = TestParameter.getParameters(testClass, methods);

test = cell(size(methods));
test = repmat({test}, 1, numel(methodSetupParameters));
test = repmat({test}, 1, numel(classSetupParameters));

for classSetupParameterIdx = 1:numel(classSetupParameters)
    classParameter = classSetupParameters{classSetupParameterIdx};
    
    for methodSetupParameterIdx = 1:numel(methodSetupParameters)
        methodParameter = methodSetupParameters{methodSetupParameterIdx};
        
        for methodIdx = 1:numel(methods)
            currentMethod = methods(methodIdx);
            currentProvider = createProvider(currentMethod);
            
            testParameters = testParameterMap(currentMethod.Name);
            
            % Determine the set of parameters to use for this method.
            parameters = cell(1, numel(testParameters));
            selectMask = true(size(parameters));
            
            for paramIdx = 1:numel(testParameters)
                parameters{paramIdx} = [classParameter, methodParameter, testParameters{paramIdx}];
                
                % Filter on parameters
                paramAttribute = SelectionAttribute.empty;
                if usesParameter
                    paramAttribute = ParameterAttribute(parameters{paramIdx});
                end
                
                % Filter on name
                nameAttribute = SelectionAttribute.empty;
                if usesName
                    name = getTestName(classParameter, methodParameter, ...
                        testParameters{paramIdx}, testClass.Name, currentMethod.Name);
                    nameAttribute = NameAttribute(name);
                end
                
                % Make the final selection decision based on all attributes
                attributes = [folderAttribute, fixtureAttribute, paramAttribute, nameAttribute];
                selectMask(paramIdx) = selector.select(attributes);
            end
            
            parameters = parameters(selectMask);
            
            % Preallocate
            testForCurrentMethod = repmat(matlab.unittest.Test, 1, numel(parameters));
            
            % Construct suite elements
            for paramIdx = 1:numel(parameters)
                testForCurrentMethod(paramIdx) = matlab.unittest.Test( ...
                    currentProvider, sharedTestFixtures, parameters{paramIdx});
            end
            
            test{classSetupParameterIdx}{methodSetupParameterIdx}{methodIdx} = testForCurrentMethod;
        end
    end
end

% Flatten the suite
test = [test{:}];
test = [test{:}];
test = [matlab.unittest.Test.empty, test{:}];

% If possible, reshape the suite back to shape of the methods
if numel(test) == numel(methods)
    test = reshape(test, size(methods));
end
end

function parameters = constructParameters(paramInfo, allParamPropNames, name, paramType, fromNameMethod)
import matlab.unittest.parameters.EmptyParameter;

% Make sure the correct set of parameters was specified
if ~isempty(setxor(allParamPropNames, {paramInfo.Property}))
    if isempty(allParamPropNames)
        error(message('MATLAB:unittest:TestSuite:NoParametersNeeded', ...
            paramType));
    else
        error(message('MATLAB:unittest:TestSuite:IncorrectParameters', ...
            paramType, name, strjoin(allParamPropNames,', ')));
    end
end

numParameters = numel(paramInfo);
parameters(1:numParameters) = EmptyParameter;
for idx = 1:numParameters
    parameters(idx) = fromNameMethod(paramInfo(idx).Property, paramInfo(idx).Name);
end
end

function fixtures = determineSharedTestFixtures(testClass)
import matlab.unittest.internal.getAllTestCaseClassesInHierarchy;
import matlab.unittest.fixtures.EmptyFixture;

classes = getAllTestCaseClassesInHierarchy(testClass);
sharedTestFixtures = [classes.SharedTestFixtures];
sharedTestFixtures = [EmptyFixture.empty, sharedTestFixtures{:}];
sharedTestFixtures = getUniqueTestFixtures(sharedTestFixtures);

% Make a copy to keep from modifying the fixture handles stored on the
% metaclass.
fixtures = copy(sharedTestFixtures);
end

function name = getTestName(classParams, methodParams, testParams, parentName, testName)
classSetupParamsStr = getParameterNameString(classParams, '[', ']');
methodSetupParamsStr = getParameterNameString(methodParams, '[', ']');
testParamsStr = getParameterNameString(testParams, '(', ')');

name = [parentName, classSetupParamsStr, '/', ...
    methodSetupParamsStr, testName, testParamsStr];
end

function str = getParameterNameString(params, leftBracket, rightBracket)
if isempty(params)
    str = '';
    return;
end

propNames = {params.Property};
paramNames = {params.Name};

numParams = numel(propNames);
propAndParamNames = cell(1,numParams);
for idx = 1:numParams
    propAndParamNames{idx} = [propNames{idx} '=' paramNames{idx}];
end

str = [leftBracket, strjoin(propAndParamNames,','), rightBracket];
end

function fixture = findFixture(fixtureArray, className)
fixture = fixtureArray(find(arrayfun(@(f)isa(f,className), fixtureArray), 1, 'first'));
end

function newFixtures = fixtureConverter(oldFixtures)

% Build a map of supported conversions from R2013a fixtures
fixtureMap = containers.Map('KeyType','char', 'ValueType','any');
fixtureMap('matlab.unittest.internal.fixtures.PathFixture') = ...
    @matlab.unittest.internal.fixtures.HiddenPathFixture;
fixtureMap('matlab.unittest.internal.fixtures.CurrentFolderFixture') = ...
    @matlab.unittest.internal.fixtures.HiddenCurrentFolderFixture;

newFixtures = arrayfun(@(f)feval(fixtureMap(f.FixtureClassName), f.Parameters{:}), ...
    oldFixtures, 'UniformOutput',false);

newFixtures = [matlab.unittest.fixtures.EmptyFixture.empty, newFixtures{:}];
end

function baseFolder = getBaseFolder(testParentName)
baseFolder = fileparts(which(testParentName));

% Remove package folders
packageIdx = strfind(baseFolder, [filesep, '+']);
if ~isempty(packageIdx)
    baseFolder = baseFolder(1:packageIdx(1)-1);
end

% Remove class folders
classIdx = strfind(baseFolder, [filesep, '@']);
if ~isempty(classIdx)
    baseFolder = baseFolder(1:classIdx(1)-1);
end
end

% LocalWords:  c'tor Teardownable