classdef localMethod < helpUtils.classInformation.method
    methods
        function ci = localMethod(classWrapper, className, basePath, derivedPath, derivedClass, methodName, packageName)
            definition = fullfile(basePath, [className filemarker methodName]);
            minimalPath = fullfile(derivedPath, [derivedClass filemarker methodName]);
            whichTopic = fullfile(basePath, [className '.m']);
            ci@helpUtils.classInformation.method(classWrapper, packageName, className, methodName, definition, minimalPath, whichTopic);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
