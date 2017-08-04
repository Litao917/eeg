function results = runtests(tests, varargin)
% runtests - Run a set of tests.
%
%   The runtests function provides a simple way to run a collection of
%   tests. 
%
%   RESULT = runtests(TESTS) creates a test suite specified by TESTS, runs
%   them, and returns the RESULT. TESTS can be a string containing the name
%   of a test class, a test file, a package that contains the desired
%   test classes, or a folder that contains the desired test files. TESTS
%   can also be a cell array of strings where each element of the cell
%   array is a string specifying a test suite in this manner.
%
%   RESULT = runtests(TESTS, 'Recursively', true) also runs all the tests
%   defined in the subfolders of any specified folders and in the
%   subpackages of any specified packages.
%
%   SUITE = runtests(TESTS, ATTRIBUTE_1, CONSTRAINT_1, ...) runs all the
%   tests specified by TESTS that satisfy the specified conditions. Specify
%   any of the following attributes:
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
%   "?" (matches exactly one character). A test is run only if it satisfies
%   all the specified criteria.
%   
%
%   Examples:
%
%       % Run tests using a variety of methods.
%       results = runtests('mypackage.MyTestClass')
%       results = runtests('SomeTestFile.m')
%       results = runtests(pwd)
%       results = runtests('mypackage.subpackage')
%
%       % Run them all in one function call
%       result = runtests({'mypackage.MyTestClass', 'SomeTestFile.m', ...
%            'mypackage.subpackage', pwd})
%
%       % Run all the tests in the current folder and any subfolders, but
%       % require that the name "feature1" appear somewhere in the folder name.
%       result = runtests(pwd, 'Recursively',true, 'BaseFolder','*feature1*');
%
%   See also: functiontests, matlab.unittest.TestSuite, matlab.unittest.TestRunner, matlab.unittest.TestResult
%


% Copyright 2013 The MathWorks, Inc.

import matlab.unittest.internal.selectors.convertParsingResultsToSelector;

parser = inputParser;
parser.addParameter('Recursively', false, @validateRecursively);
parser.addParameter('ParameterProperty',[]);
parser.addParameter('ParameterName',[]);
parser.addParameter('Name',[]);
parser.addParameter('BaseFolder',[]);
parser.parse(varargin{:});

results = rmfield(parser.Results, parser.UsingDefaults);
selector = convertParsingResultsToSelector(results);

suites = cellfun(@(test)createSuite(test, selector, parser.Results.Recursively), ...
    cellstr(tests), 'UniformOutput', false);

results = run([matlab.unittest.Test.empty, suites{:}]);
end

function suite = createSuite(tests, selector, recursively)

import matlab.unittest.TestSuite;
import matlab.unittest.internal.isConcreteTestCase;

class = meta.class.fromName(tests);
if exist(tests,'class') && isConcreteTestCase(class)
    suite = TestSuite.fromClass(class, selector);
elseif isequal(exist(tests, 'file'), 2)
    file = which(tests);
    if isempty(file)
        file = tests;
    end
    suite = TestSuite.fromFile(file, selector);
elseif ~isempty(meta.package.fromName(tests))
    if recursively
        suite = TestSuite.fromPackage(tests, selector, 'IncludingSubpackages', true);
    else
        suite = TestSuite.fromPackage(tests, selector);
    end
elseif exist(tests, 'dir')
    if recursively
        suite = TestSuite.fromFolder(tests, selector, 'IncludingSubfolders', true);
    else
        suite = TestSuite.fromFolder(tests, selector);
    end
else
    error(message('MATLAB:unittest:runtests:UnrecognizedSuite', tests));
end
end

function validateRecursively(value)
validateattributes(value, {'numeric','logical'}, {'scalar'}, '' ,'Recursively')
end

% LocalWords:  subfolders subpackages mypackage
