function name = getSimpleClassName(name)
% This function is undocumented.

%  Copyright 2012 MathWorks, Inc.

idx = strfind(name,'.');
if ~isempty(idx);
    name = name(idx(end)+1:end);
end
