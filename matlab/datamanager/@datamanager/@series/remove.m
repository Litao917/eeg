function remove(this,keepflag)
% This undocumented function may be removed in a future release.

% Remove brushed data from the @series

% Copyright 2013 The MathWorks, Inc.

[~,pvPairs] = datamanager.createRemovedProperties(this.HGHandle,keepflag);
if ~isempty(pvPairs)
    set(this.HGHandle,pvPairs{:});
end