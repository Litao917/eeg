classdef packagedFunction < helpUtils.classInformation.packagedItem
    methods
        function ci = packagedFunction(packageName, packagePath, itemName)
            ci@helpUtils.classInformation.packagedItem(packageName, packagePath, itemName, [itemName '.m']);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
