classdef packagedUnknown < helpUtils.classInformation.packagedItem
    properties
        helpFunction = '';
    end
    
    methods
        function ci = packagedUnknown(packageName, packagePath, itemName, itemFullName, helpFunction)
            ci@helpUtils.classInformation.packagedItem(packageName, packagePath, itemName, itemFullName);
            ci.helpFunction = helpFunction;
        end
    end
    
    methods (Access=protected)
        function [helpText, needsHotlinking, suppressedImplicit] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            helpText = helpUtils.callHelpFunction(ci.helpFunction, ci.whichTopic);
            needsHotlinking = true;
            suppressedImplicit = false;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
