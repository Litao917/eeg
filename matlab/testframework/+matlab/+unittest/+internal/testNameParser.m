function [parentName, testName, parameters] = testNameParser(str)
% This function is undocumented.

%  Copyright 2013 MathWorks, Inc.

validateattributes(str, {'char'}, {'row'}, '', 'name');

results = regexp(str, '^(?<ParentName>[\.\w]+)(?<ClassParameters>\[[=,\w]+\])?/(?<MethodParameters>\[[=,\w]+\])?(?<TestName>\w+)(?<TestParameters>\([=,\w]+\))?$', 'names');

if isempty(results)
    error(message('MATLAB:unittest:TestSuite:InvalidName', str));
end

parentName = results.ParentName;
testName = results.TestName;

parameters.ClassSetup = parseParameters(results.ClassParameters, str);
parameters.MethodSetup = parseParameters(results.MethodParameters, str);
parameters.TestMethod = parseParameters(results.TestParameters, str);
end

function parameterStruct = parseParameters(paramStr, completeStr)
% Parse strings containing parameter pairs separated by commas, e.g.,
% '[p1=v1,p2=v2,p3=v3]' or '(p1=v1)' or ''

if isempty(paramStr)
    parameterStruct = struct('Property',{}, 'Name',{});
    return;
end

% Strip off brackets or parens and separate the parameter pairs
parameters = strsplit(paramStr(2:end-1), ',', 'CollapseDelimiters', false);

parameterCell = regexp(parameters, '^(?<Property>\w+)=(?<Name>\w+)$', 'names');
if any(cellfun(@isempty, parameterCell))
    error(message('MATLAB:unittest:TestSuite:InvalidName', completeStr));
end

parameterStruct = [parameterCell{:}];
end

% LocalWords:  parens strsplit
