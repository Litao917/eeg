function wrapped = wrapHeader(str)
% This function is undocumented.

%  Copyright 2012 MathWorks, Inc.

import matlab.unittest.internal.diagnostics.getStringDisplayWidth;

dashes = repmat('-', 1, getStringDisplayWidth(str));
wrapped = sprintf('%s\n%s\n%s', dashes, str, dashes);
end
