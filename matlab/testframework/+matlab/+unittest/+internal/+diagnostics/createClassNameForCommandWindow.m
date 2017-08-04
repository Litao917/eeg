function name = createClassNameForCommandWindow(name)
% This function is undocumented.

%  Copyright 2012 MathWorks, Inc.

import matlab.unittest.internal.diagnostics.shouldHyperLink;
import matlab.unittest.internal.diagnostics.getSimpleClassName;

if shouldHyperLink()
    name = sprintf('%s',...
        '<a href="matlab:helpPopup ', name, '" style="font-weight:bold">', ...
        getSimpleClassName(name), '</a>');
else
    name = getSimpleClassName(name);
end

