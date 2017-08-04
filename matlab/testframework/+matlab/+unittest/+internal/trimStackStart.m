function stack = trimStackStart(stack)
% This function is undocumented.

%  Copyright 2013 MathWorks, Inc.

% Trim the start

files = {stack.file};
frameworkFolder = getFrameworkFolder;
testContentFrames = ~strncmp(files, frameworkFolder, numel(frameworkFolder));
firstTestContentFrame = find(testContentFrames,1);
if isempty(firstTestContentFrame)
    stack(:) = [];
else
    stack(1:firstTestContentFrame-1) = [];
end
