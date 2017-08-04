classdef TestSuite
    % TestSuite - Interface for grouping tests to run
    %
    %   The matlab.unittest.TestSuite class is the fundamental interface used
    %   to group and run a set of tests using matlab.unittest. The
    %   TestRunner can only run arrays of TestSuites.
    %
    %   TestSuites are created using static methods of the TestSuite class.
    %   These methods may return subclasses of TestSuite depending on
    %   the method call and context.
    %
    %   TestSuite methods:
    %       fromName    - Create a suite from the name of the test element
    %       fromFile    - Create a suite from a TestCase class filename
    %       fromFolder  - Create a suite from all tests in a folder
    %       fromPackage - Create a suite from all tests in a package
    %       fromClass   - Create a suite from a TestCase class
    %       fromMethod  - Create a suite from a single test method
    %
    %       run      - Run a TestSuite using a TestRunner configured for text output
    %       selectIf - Select suite elements that satisfy one or more constraints
    %
    %   Example:
    %
    %       import matlab.unittest.TestSuite;
    %
    %       % Create test suites using a variety of methods.
    %       fileSuite    = TestSuite.fromFile('SomeTestFile.m');
    %       folderSuite  = TestSuite.fromFolder(pwd);
    %       packageSuite = TestSuite.fromPackage('mypackage.subpackage');
    %       classSuite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       methodSuite  = TestSuite.fromMethod(?SomeTestClass,'testMethod');
    %
    %       % Now concatenate them all together and run them using a test
    %       % runner configured  for text output.
    %       largeSuite = [fileSuite, folderSuite, packageSuite, classSuite, methodSuite];
    %
    %       % Run the full suite
    %       result = run(largeSuite)
    %
    %   See also: TestRunner, TestResult, Test
    %
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    methods (Static)
        function suite = fromName(name)
            % fromName - Create a suite from the name of the test element
            %
            %   SUITE = matlab.unittest.TestSuite.fromName(NAME) creates a scalar
            %   TestSuite given its name and returns it in SUITE. NAME is a string
            %   corresponding to the name of the Test suite array element to be
            %   created. The name of a test element contains the name of the TestCase
            %   class or function as well as the test method or local function. The
            %   name also contains information about parameterization.
            %
            %   The test class or function described by NAME must be on the MATLAB path
            %   when creating SUITE using this method as well as when SUITE is run.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %
            %       % Create a suite for the "TestFoo" method in class "MyTest"
            %       suite = TestSuite.fromName('MyTest/TestFoo');
            %       result = run(suite)
            %
            %       % Create a suite for the "TestFoo" method in class "MyTest" with
            %       % TestParameter "Param".
            %       suite = TestSuite.fromName('MyTest/TestFoo(Param=val)');
            %       result = run(suite)
            %
            %   See also: TestRunner
            %
            
            suite = matlab.unittest.Test.fromName(name);
        end
        
        function suite = fromFile(testFile, varargin)
            % fromFile - Create a suite from a test file
            %
            %   SUITE = matlab.unittest.TestSuite.fromFile(FILE) creates a TestSuite
            %   array from all of the Test methods in FILE and returns that array in
            %   SUITE. FILE is a string corresponding to the name of the desired file.
            %   FILE can contain either an absolute or relative path to the desired
            %   file.
            %
            %   SUITE = matlab.unittest.TestSuite.fromFile(FILE, ATTRIBUTE_1, CONSTRAINT_1, ...)
            %   creates a TestSuite array for all of the Test methods in FILE that
            %   satisfy the specified conditions. Specify any of the following attributes:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). An element is included in the
            %   TestSuite array only if it satisfies all the specified criteria.
            %
            %   SUITE = matlab.unittest.TestSuite.fromFile(FILE, SELECTOR) creates a
            %   TestSuite array for all of the Test methods contained in TESTCLASS that
            %   satisfy the SELECTOR.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasParameter;
            %
            %       % Create a suite for the file "MyTestFile.m"
            %       suite = TestSuite.fromFile('MyTestFile.m');
            %       result = run(suite)
            %
            %       % Create a suite for the Test methods in file
            %       % "MyTest.m" whose name starts with "TestFoo".
            %       suite = TestSuite.fromFile('MyTest.m', 'Name','TestFoo*');
            %       result = run(suite)
            %
            %       % Create a suite for all parameterized Test methods in "MyTest.m"
            %       suite = TestSuite.fromFile('MyTest.m', HasParameter);
            %       result = run(suite)
            %
            %   See also: TestRunner, TestSuite.fromFolder, matlab.unittest.selectors
            %
            
            import matlab.unittest.Test;
            
            import matlab.unittest.internal.isFunctionalTestCase;
            import matlab.unittest.internal.ScriptTestCaseProvider;
            import matlab.unittest.internal.TestScriptFileModel;
            
            validateattributes(testFile, {'char'}, {'row'}, '', 'File');
            
            if ~exist(testFile,'file')
                error(message('MATLAB:unittest:TestSuite:InvalidFile', testFile));
            end
            
            [containingFolder, filename, ext] = fileparts(testFile);
            
            if ~strcmp(ext,'.m') && ~strcmp(ext,'.p')
                error(message('MATLAB:unittest:TestSuite:InvalidMATLABFile', testFile));
            end
            
            if ~strcmp(ext,'.p')
                possiblyShadowingPFile = fullfile(containingFolder, [filename, '.p']);
                if any(exist(possiblyShadowingPFile, 'file') == [2, 6])
                    error(message('MATLAB:unittest:TestSuite:ShadowedByPFile', testFile));
                end
            end
            
            selector = parseInputsToSelector(varargin{:});
            
            [~, folderInfo] = fileattrib(containingFolder);
            fullFolderPath = folderInfo.Name;
            validateFolder(fullFolderPath, false);
            cl = temporarilyAddToPathAndChangeFolder(fullFolderPath); %#ok<NASGU>
            
            metaClass = meta.class.fromName(filename);
            if isempty(metaClass)
                whichFile = which(filename);
                if isFunctionalTestCase(whichFile)
                    suite = feval(filename);
                    suite = suite.selectIf(selector);
                else
                    [isscript, parseTree] = TestScriptFileModel.isScript(whichFile);
                    if isscript
                        scriptModel = TestScriptFileModel(whichFile, parseTree);
                        provider = ScriptTestCaseProvider(scriptModel);
                        suite = Test.fromProvider(provider);
                        suite = suite.selectIf(selector);
                    else
                        error(message('MATLAB:unittest:TestSuite:NonTestFile', testFile));
                    end
                end
            else
                suite = matlab.unittest.TestSuite.fromClass(metaClass, selector);
            end
            suite = addPathAndCDFixtures(suite, fullFolderPath);
        end
        
        function suite = fromClass(testClass, varargin)
            % fromClass - Create a suite from a TestCase class
            %
            %   SUITE = matlab.unittest.TestSuite.fromClass(TESTCLASS) creates a
            %   TestSuite array from all of the Test methods contained in TESTCLASS and
            %   returns that array in SUITE. TESTCLASS is a meta.class instance which
            %   describes the desired test class. The test class described by TESTCLASS
            %   must derive from matlab.unittest.TestCase.
            %
            %   This test class must be on the MATLAB path when creating SUITE using
            %   this method as well as when SUITE is run.
            %
            %   SUITE = matlab.unittest.TestSuite.fromClass(TESTCLASS, ATTRIBUTE_1, CONSTRAINT_1, ...)
            %   creates a TestSuite array for all of the Test methods in TESTCLASS that
            %   satisfy the specified conditions. Specify any of the following attributes:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). An element is included in the
            %   TestSuite array only if it satisfies all the specified criteria.
            %
            %   SUITE = matlab.unittest.TestSuite.fromClass(TESTCLASS, SELECTOR)
            %   creates a TestSuite array for all of the Test methods contained in
            %   TESTCLASS that satisfy the SELECTOR.
            %
            %   This test class must be on the MATLAB path when creating SUITE using
            %   this method as well as when SUITE is run.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasParameter;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       result = run(suite)
            %
            %       % Create a suite for the Test methods in class
            %       % MyTest whose name starts with "TestFoo".
            %       suite = TestSuite.fromClass(?MyTest, 'Name','TestFoo*');
            %       result = run(suite)
            %
            %       % Create a suite for all parameterized Test methods in MyTest
            %       suite = TestSuite.fromClass(?MyTest, HasParameter);
            %       result = run(suite)
            %
            %   See also: TestRunner, TestSuite.fromMethod, TestSuite.fromPackage, matlab.unittest.selectors
            %
            
            selector = parseInputsToSelector(varargin{:});
            suite = matlab.unittest.Test.fromClass(testClass, selector);
        end
        
        function suite = fromMethod(testClass, testMethod, varargin)
            % fromMethod - Create a suite from a single test method
            %
            %   SUITE = matlab.unittest.TestSuite.fromMethod(TESTCLASS, TESTMETHOD)
            %   creates a TestSuite from the test class described by TESTCLASS and the
            %   test method described by TESTMETHOD and returns it in SUITE. TESTCLASS
            %   is a meta.class instance which describes the desired test class. The
            %   test class described by TESTCLASS must be a subclass of
            %   matlab.unittest.TestCase. Additionally, this test class must be on the
            %   MATLAB path when creating the TestSuite using this method as well as
            %   when the test is run. TESTMETHOD is either the meta.method instance
            %   which describes the desired test method or the name of the desired test
            %   method as a string. The method must be defined with a true Test method
            %   attribute.
            %
            %   SUITE = matlab.unittest.TestSuite.fromMethod(TESTCLASS, TESTMETHOD, ATTRIBUTE_1, CONSTRAINT_1, ...)
            %   creates a TestSuite array from the test class described by TESTCLASS
            %   and the test method described by TESTMETHOD that satisfy the specified
            %   conditions. Specify any of the following attributes:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). An element is included in the
            %   TestSuite array only if it satisfies all the specified criteria.
            %
            %   SUITE = matlab.unittest.TestSuite.fromMethod(TESTCLASS, TESTMETHOD, SELECTOR)
            %   creates a TestSuite array from the test class described by
            %   TESTCLASS and the test method described by TESTMETHOD that
            %   satisfy the SELECTOR.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasParameter;
            %
            %       cls = ?mypackage.MyTestClass;
            %
            %       % Create the suite using the method name
            %       suite = TestSuite.fromMethod(cls, 'testMethod');
            %       result = run(suite)
            %
            %       % Create the suite using the meta.method instance
            %       metaMethod = findobj(cls.MethodList, 'Name', 'testMethod');
            %       suite = TestSuite.fromMethod(cls, metaMethod);
            %       result = run(suite)
            %
            %       % Create a suite for only certain parameters
            %       suite = TestSuite.fromMethod(cls, 'testMethod', ...
            %           HasParameter('Name','Param*'));
            %       result = run(suite)
            %
            %   See also: TestRunner, TestSuite.fromClass, TestSuite.fromPackage, matlab.unittest.selectors
            %
            
            selector = parseInputsToSelector(varargin{:});
            suite = matlab.unittest.Test.fromMethod(testClass, testMethod, selector);
        end
        
        function suite = fromPackage(package, varargin)
            % fromPackage - Create a suite from all tests in a package
            %
            %   SUITE = matlab.unittest.TestSuite.fromPackage(PACKAGE) creates a
            %   TestSuite array from all of the Test methods of all concrete TestCase
            %   classes contained in PACKAGE and returns that array in SUITE. PACKAGE
            %   is a string corresponding to the name of the desired package to find
            %   tests. The method is not recursive, returning only those tests directly
            %   in the package specified.
            %
            %   SUITE = matlab.unittest.TestSuite.fromPackage(PACKAGE, 'IncludingSubpackages', true)
            %   creates a TestSuite array from all of the Test methods of all
            %   concrete TestCase classes contained in PACKAGE and any
            %   of its subpackages.
            %
            %   SUITE = matlab.unittest.TestSuite.fromPackage(PACKAGE, ATTRIBUTE_1, CONSTRAINT_1, ...)
            %   creates a TestSuite array from all of the Test methods of all concrete
            %   TestCase classes contained in PACKAGE that satisfy the specified
            %   conditions. Specify any of the following attributes:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). An element is included in the
            %   TestSuite array only if it satisfies all the specified criteria.
            %
            %   SUITE = matlab.unittest.TestSuite.fromPackage(PACKAGE, SELECTOR)
            %   creates a TestSuite array from all of the Test methods of
            %   all concrete TestCase classes contained in PACKAGE that
            %   satisfy the SELECTOR.
            %
            %   The base folder(s) where PACKAGE is defined must be on the MATLAB path
            %   when creating SUITE using this method as well as when SUITE is run.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %
            %       suite = TestSuite.fromPackage('mypackage.subpackage');
            %       result = run(suite)
            %
            %       % Create a suite for all parameterized Test methods in mypackage
            %       suite = TestSuite.fromPackage('mypackage', HasParameter);
            %       result = run(suite)
            %
            %   See also: TestRunner, TestSuite.fromClass, TestSuite.fromMethod, matlab.unittest.selectors
            %
            
            import matlab.unittest.TestSuite;
            
            parser = createSelectionParser;
            parser.addParamValue('IncludingSubpackages',false, @validateIncludingSubpackagesTrue);
            parser.parse(varargin{:});
            selector = parsingResultsToSelector(parser);
            
            pkg = meta.package.fromName(package);
            
            if isempty(pkg)
                error(message('MATLAB:unittest:TestSuite:InvalidPackage', package));
            end
            
            folderName = ['+', strrep(pkg.Name, '.', [filesep, '+'])];
            allFolderInfo = what(folderName);
            nFolders = numel(allFolderInfo);
            suites = cell(1, nFolders);
            
            % Iterate over all the folders that define the package
            for folderIdx = 1:nFolders
                thisFolderInfo = allFolderInfo(folderIdx);
                
                % Get all executable files and remove extension
                files = [thisFolderInfo.m, thisFolderInfo.p];
                for fileIdx = 1:numel(files)
                    [~, files{fileIdx}] = fileparts(files{fileIdx});
                end
                
                % Filter duplicate entries (e.g., M and P files)
                files = unique(files);
                
                % Include any classes in "@" folders
                shortClassNames = [files, thisFolderInfo.classes];
                
                nClasses = numel(shortClassNames);
                testClasses = repmat({createEmptyMetaClass}, 1, nClasses);
                
                for classIdx = 1:nClasses
                    fullClassName = [pkg.Name, '.', shortClassNames{classIdx}];
                    testClasses{classIdx} = getTestCaseMetaClass(fullClassName);
                end
                
                suites{folderIdx} = createSuiteFromClasses([testClasses{:}], selector);
            end
            
            suite = [suites{:}];
            
            % Recursively build up suites in any subpackages.
            if parser.Results.IncludingSubpackages
                subSuites = cellfun(@(pk)TestSuite.fromPackage(pk, selector, 'IncludingSubpackages',true), ...
                    {pkg.PackageList.Name}, 'UniformOutput',false);
                
                suite = [suite, subSuites{:}];
            end
        end
        
        function suite = fromFolder(folder, varargin)
            % fromFolder - Create a suite from all tests in a folder
            %
            %   SUITE = matlab.unittest.TestSuite.fromFolder(FOLDER) creates a
            %   TestSuite array from all of the Test methods of all concrete TestCase
            %   classes contained in FOLDER and returns that array in SUITE. FOLDER is
            %   a string corresponding to the name of the desired folder to find tests.
            %   FOLDER can either be an absolute or relative path to the desired
            %   folder.
            %
            %   SUITE = matlab.unittest.TestSuite.fromFolder(FOLDER, 'IncludingSubfolders', true)
            %   creates a TestSuite array from all of the Test methods of all
            %   concrete TestCase classes contained in FOLDER and any
            %   of its subfolders, excluding package, class, and private folders.
            %
            %   SUITE = matlab.unittest.TestSuite.fromFolder(FOLDER, ATTRIBUTE_1, CONSTRAINT_1, ...)
            %   creates a TestSuite array from all of the Test methods of all concrete
            %   TestCase classes contained in FOLDER that satisfy the specified
            %   conditions. Specify any of the following attributes:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). An element is included in the
            %   TestSuite array only if it satisfies all the specified criteria.
            %
            %   SUITE = matlab.unittest.TestSuite.fromFolder(FOLDER, SELECTOR) creates
            %   a TestSuite array from all of the Test methods of all concrete TestCase
            %   classes contained in FOLDER that satisfy the SELECTOR.
            %
            %   Examples:
            %       import matlab.unittest.TestSuite;
            %
            %       suite = TestSuite.fromFolder(pwd);
            %       result = run(suite)
            %
            %       % Include only select folders
            %       suite = TestSuite.fromFolder(pwd, 'IncludingSubfolders',true, ...
            %           'BaseFolder','TestFeature1');
            %       result = run(suite)
            %
            %   See also: TestRunner, TestSuite.fromFile, matlab.unittest.selectors
            %
            
            import matlab.unittest.TestSuite;
            import matlab.unittest.Test;
            import matlab.unittest.internal.selectors.BaseFolderAttribute;
            import matlab.unittest.internal.isFunctionalTestCase;
            import matlab.unittest.internal.DefaultTestNameMatcher;
            
            parser = createSelectionParser;
            parser.addParamValue('IncludingSubfolders',false, @validateIncludingSubfoldersTrue);
            parser.parse(varargin{:});
            selector = parsingResultsToSelector(parser);
            
            [status, folderInfo] = fileattrib(folder);
            if ~(status && folderInfo.directory)
                error(message('MATLAB:unittest:TestSuite:InvalidFolder', folder));
            end
            
            fullFolderPath = folderInfo.Name;
            validateFolder(fullFolderPath, true);
            fileAndFolderInfo = dir(fullFolderPath);
            
            if selector.uses(?matlab.unittest.internal.selectors.BaseFolderAttribute) && ...
                    ~selector.select(BaseFolderAttribute(fullFolderPath))
                % If the selector rejects the folder, we need not examine
                % any content at all inside the folder.
                suite = Test.empty(1,0);
            else
                % Make sure these classes are in the current folder while we construct the suite.
                cl = temporarilyAddToPathAndChangeFolder(fullFolderPath); %#ok<NASGU>
                
                files = {fileAndFolderInfo(~[fileAndFolderInfo.isdir]).name};
                
                % Find the TestCase classes
                nFiles = numel(files);
                testSuites = repmat({Test.empty}, 1, nFiles);
                for idx = 1:numel(files)
                    thisFile = files{idx};
                    [~, filename, ext] = fileparts(thisFile);
                    
                    if ~strcmp(ext,'.m') && ~strcmp(ext,'.p')
                        continue;
                    end
                    
                    if ~strcmp(ext,'.p') && any(strcmp(files, [filename, '.p']))
                        % Shadowed by a P-file
                        continue;
                    end
                    
                    testCaseClass = getTestCaseMetaClass(filename);
                    if isempty(testCaseClass) && ...
                            DefaultTestNameMatcher.isTest(filename) && ...
                            isFunctionalTestCase(fullfile(fullFolderPath, thisFile))
                        testSuites{idx} = selectIf(feval(filename), selector);
                    else
                        testSuites{idx} = createSuiteFromClasses(testCaseClass, selector);
                    end
                end
                
                % Build the suite from the cell array of individual suites
                suite = [testSuites{:}];
                suite = addPathAndCDFixtures(suite, fullFolderPath);
            end
            
            % Recursively build up suites in any subfolders.
            if parser.Results.IncludingSubfolders
                subfolders = {fileAndFolderInfo([fileAndFolderInfo.isdir]).name};
                subfolders = filterSubfolders(subfolders);
                
                subSuites = cellfun(@(fld)TestSuite.fromFolder(fld, selector, 'IncludingSubfolders',true), ...
                    fullfile(fullFolderPath, subfolders), 'UniformOutput',false);
                
                suite = [suite, subSuites{:}];
            end
        end
        
    end
    
    methods(Sealed)
        function results = run(suite)
            % RUN - Run a TestSuite using a TestRunner configured for text output
            %
            %   RESULT = RUN(SUITE) runs the TestSuite defined by SUITE using a
            %   TestRunner configured for text output. This is a convenience method
            %   which is equivalent to using a TestRunner created from
            %   TestRunner.withTextOutput to run SUITE. RESULT is a
            %   matlab.unittest.TestResult containing the result of the test run.
            %   RESULT is the same size as SUITE and each element is the result of the
            %   corresponding element in SUITE.
            %
            %   Example:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.TestRunner;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %       runner = TestRunner.withTextOutput;
            %
            %       % Following test runs are equivalent
            %       result = runner.run(suite)
            %       result = run(suite)
            %
            %   See also: TestRunner, TestCase, TestResult
            %
            
            import matlab.unittest.TestRunner;
            
            runner = TestRunner.withTextOutput;
            results = runner.run(suite);
            
        end
        
        function newSuite = selectIf(suite, varargin)
            % SELECTIF - Select suite elements that satisfy one or more constraints
            %
            %   NEWSUITE = SELECTIF(SUITE, ATTRIBUTE_1, CONSTRAINT_1, ..., ATTRIBUTE_N, CONSTRAINT_N)
            %   returns in NEWSUITE the TestSuite elements in SUITE that satisfy the
            %   specified conditions. This method accepts any number of the following
            %   name/value pairs:
            %
            %       * Name              - Name of the suite element
            %       * ParameterProperty - Name of a property that defines a
            %                             Parameter used by the suite element
            %       * ParameterName     - Name of a Parameter used by the suite element
            %       * BaseFolder        - Name of the folder that holds the file
            %                             defining the test class or function.
            %
            %   Each value is specified as a string. The string may contain wildcard
            %   characters "*" (matches any number of characters, including zero) and
            %   "?" (matches exactly one character). Only those TestSuite array
            %   elements which satisfy all the constraints are returned.
            %
            %   NEWSUITE = SELECTIF(SELECTOR) returns in NEWSUITE the TestSuite
            %   elements in SUITE that satisfy the conditions specified by SELECTOR.
            %
            %   Example:
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasSharedTestFixture;
            %       import matlab.unittest.selectors.HasParameter;
            %       import matlab.unittest.fixtures.PathFixture;
            %       import matlab.unittest.constraints.StartsWithSubstring;
            %
            %       suite = TestSuite.fromClass(?mypackage.MyTestClass);
            %
            %       % Select TestSuite array elements for test methods whose names end
            %       % with the string "bar".
            %       newSuite = suite.selectIf('Name', '*bar');
            %
            %       % Select TestSuite array elements using a parameter defined by a
            %       % property named "Param1" with parameter name "Foo"
            %       newSuite = suite.selectIf('ParameterProperty','Param1', 'ParameterName','Foo');
            %
            %       % Select TestSuite array elements for classes defined in a folder
            %       % named "testBar".
            %       suite = TestSuite.fromFolder(pwd, 'IncludingSubfolders', true);
            %       newSuite = suite.selectIf('BaseFolder', [filesep, '*testBar']);
            %
            %       % Select TestSuite array elements which use a PathFixture
            %       newSuite = suite.selectIf(HasSharedTestFixture(PathFixture));
            %
            %       % Select TestSuite array elements that are not parameterized and
            %       % whose name begins with "foobar".
            %       newSuite = suite.selectIf(~HasParameter & HasName(StartsWithSubstring('foobar')));
            %
            %   See also: matlab.unittest.constraints, matlab.unittest.selectors
            %
            
            import matlab.unittest.TestSuite;
            import matlab.unittest.internal.selectors.SelectionAttribute;
            import matlab.unittest.internal.selectors.ParameterAttribute;
            import matlab.unittest.internal.selectors.SharedTestFixtureAttribute;
            import matlab.unittest.internal.selectors.NameAttribute;
            import matlab.unittest.internal.selectors.BaseFolderAttribute;
            
            narginchk(2, Inf);
            
            
            selector = parseInputsToSelector(varargin{:});
            
            % Determine which attributes the selector uses
            usesBaseFolder = selector.uses(?matlab.unittest.internal.selectors.BaseFolderAttribute);
            usesName = selector.uses(?matlab.unittest.internal.selectors.NameAttribute);
            usesParameter = selector.uses(?matlab.unittest.internal.selectors.ParameterAttribute);
            usesSharedTestFixture = selector.uses(?matlab.unittest.internal.selectors.SharedTestFixtureAttribute);
            
            results = true(size(suite));
            
            for idx = 1:numel(suite)
                baseFolder = SelectionAttribute.empty;
                if usesBaseFolder
                    baseFolder = BaseFolderAttribute(suite(idx).BaseFolder);
                end
                
                name = SelectionAttribute.empty;
                if usesName
                    name = NameAttribute(suite(idx).Name);
                end
                
                parameter = SelectionAttribute.empty;
                if usesParameter
                    parameter = ParameterAttribute(suite(idx).Parameterization);
                end
                
                sharedTestFixture = SelectionAttribute.empty;
                if usesSharedTestFixture
                    sharedTestFixture = SharedTestFixtureAttribute(suite(idx).SharedTestFixtures);
                end
                
                % Determine the result of filtering using all attributes
                attributes = [baseFolder, name, parameter, sharedTestFixture];
                results(idx) = selector.select(attributes);
            end
            
            newSuite = suite(results);
        end
    end
    
    methods(Hidden, Access=protected)
        function suite = TestSuite
        end
    end
    
end

function selector = parseInputsToSelector(varargin)
parser = createSelectionParser;
parser.parse(varargin{:});
selector = parsingResultsToSelector(parser);
end

function selector = parsingResultsToSelector(parser)
import matlab.unittest.internal.selectors.convertParsingResultsToSelector;

results = rmfield(parser.Results, parser.UsingDefaults);
selector = convertParsingResultsToSelector(results);
end

function parser = createSelectionParser
parser = inputParser;
parser.CaseSensitive = true;
parser.PartialMatching = false;

parser.addOptional('Selector', []);
parser.addParameter('ParameterProperty',[]);
parser.addParameter('ParameterName',[]);
parser.addParameter('Name',[]);
parser.addParameter('BaseFolder',[]);
end

function mclass = getTestCaseMetaClass(classname)
% Get the meta.class information for a particular classname if it refers to
% a valid, concrete test class. Otherwise, return an empty meta.class.

import matlab.unittest.internal.diagnostics.indent;
import matlab.unittest.internal.isConcreteTestCase;

mclass = createEmptyMetaClass;

try
    cls = meta.class.fromName(classname);
catch me
    warning(message('MATLAB:unittest:TestSuite:FileExcluded', ...
        which(classname), indent(me.message, '    ')));
    return;
end

if isConcreteTestCase(cls)
    mclass = cls;
end
end

function suite = createSuiteFromClasses(testClasses, selector)
import matlab.unittest.Test;

nTestClasses = numel(testClasses);
suites = cell(1, nTestClasses);
for idx = 1:nTestClasses
    suites{idx} = Test.fromClass(testClasses(idx), selector);
end

% Empty test suite array must be of type Test
suite = [Test.empty, suites{:}];
end

function mclass = createEmptyMetaClass
mclass = ?matlab.unittest.TestCase;
mclass(1) = [];
end

function restore = temporarilyAddToPathAndChangeFolder(folder)
restore = matlab.unittest.internal.Teardownable;
restore.addTeardown(@path, addpath(folder));
restore.addTeardown(@cd, cd(folder));
end

function suite = addPathAndCDFixtures(suite, path)
import matlab.unittest.internal.fixtures.HiddenPathFixture;
import matlab.unittest.internal.fixtures.HiddenCurrentFolderFixture;

if ~isempty(suite)
    % Add a PathFixture and CurrentFolderFixture to ensure that this folder
    % is placed on the path at runtime and that the runner CDs to it.
    suite = suite.addFixture(HiddenPathFixture(path));
    suite = suite.addFixture(HiddenCurrentFolderFixture(path));
end
end

function result = validateIncludingSubpackagesTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','IncludingSubpacakges');
result = in; % only allow setting it to true
end

function result = validateIncludingSubfoldersTrue(in)
validateattributes(in,{'logical'},{'scalar'},'','IncludingSubfolders');
result = in; % only allow setting it to true
end

function validateFolder(folder, fromFolderFlag)
folders = regexp(folder, filesep, 'split');
leafFolder = folders{end};

if identifyPackageFolders(leafFolder)
    if fromFolderFlag
        error(message('MATLAB:unittest:TestSuite:PackageFolderNotAllowed'));
    else
        error(message('MATLAB:unittest:TestSuite:FilesInPackageFolderNotAllowed'));
    end
end

if identifyClassFolders(leafFolder)
    if fromFolderFlag
        error(message('MATLAB:unittest:TestSuite:ClassFolderNotAllowed'));
    else
        error(message('MATLAB:unittest:TestSuite:FilesInClassFolderNotAllowed'));
    end
end

if identifyPrivateFolders(leafFolder)
    if fromFolderFlag
        error(message('MATLAB:unittest:TestSuite:PrivateFolderNotAllowed'));
    else
        error(message('MATLAB:unittest:TestSuite:FilesInPrivateFolderNotAllowed'));
    end
end
end

function folders = filterSubfolders(folders)
folders(strcmp(folders, '.') | strcmp(folders, '..') | ...
    identifyPackageFolders(folders) | identifyClassFolders(folders) | ...
    identifyPrivateFolders(folders)) = [];
end

function mask = identifyPackageFolders(folders)
mask = strncmp(folders, '+', 1);
end

function mask = identifyClassFolders(folders)
mask = strncmp(folders, '@', 1);
end

function mask = identifyPrivateFolders(folders)
mask = strcmpi(folders, 'private');
end


% LocalWords:  mypackage subpackage TESTCLASS TESTMETHOD cls Subfolders PFile
% LocalWords:  subfolders mclass SELECTIF abc CDs Subpackages NEWSUITE
% LocalWords:  subpackages fld Subpacakges Teardownable
