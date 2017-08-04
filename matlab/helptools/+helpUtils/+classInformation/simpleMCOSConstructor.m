classdef simpleMCOSConstructor < helpUtils.classInformation.fileConstructor
    methods
        function ci = simpleMCOSConstructor(className, whichTopic, justChecking)
            noAtDir = isempty(regexp(whichTopic, ['[\\/]@' className '$'], 'once'));
            ci@helpUtils.classInformation.fileConstructor('', className, fileparts(whichTopic), whichTopic, noAtDir, justChecking);
        end

        function b = isClass(ci) %#ok<MANU>
            b = true;
        end
        
        function b = isMCOSClass(ci) %#ok<MANU>
            b = true;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
