function tf = shouldHyperLink

    % Copyright 2012 The MathWorks, Inc.

tf = matlab.internal.display.isHot && isempty(feature('logfile'));
% LocalWords:  logfile
