function stack = trimStackEnd(stack)
% This function is undocumented.

%  Copyright 2013 MathWorks, Inc.


% Trim the end of the stack. This means trimming all stack frames that are
% below the first call to TestRunner.runMethod and any framework stack
% frames immediately above that. The runMethod  contract is that it will
% tightly wrap all test content. Then we simply need to remove internal
% wrappers such as runTeardown and FunctionTestCase after the first
% runMethod call. Also, confirm that is it the framework's
% TestRunner.runMethod and not another class named TestRunner with a method
% named runMethod.
names = {stack.name};
runMethodIndices = find(strcmp(names, 'TestRunner.evaluateMethod'));

frameworkFolder = getFrameworkFolder;

for idx = fliplr(runMethodIndices)
    if strcmp(stack(idx).file, fullfile(frameworkFolder,'+matlab','+unittest','TestRunner.m')) 
        stack(idx:end) = [];
        break;
    end
end

files = {stack.file};
testContentFrames = ~strncmp(files, frameworkFolder, numel(frameworkFolder));
lastTestContentFrame = find(testContentFrames,1,'last');
if isempty(lastTestContentFrame)
    stack(:) = [];
else
    stack(lastTestContentFrame+1:end) = [];
end

