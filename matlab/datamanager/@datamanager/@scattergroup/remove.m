function remove(this,keepflag)
% This undocumented function may be removed in a future release.

% Remove brushed data from the @scattergroup

% Copyright 2013 The MathWorks, Inc.

% Get modified XData, YData
[I,pvPairs] = datamanager.createRemovedProperties(this.HGHandle,keepflag);

% Remove from vector-valued CData
if length(this.HGHandle.SizeData)>1
    pvPairs = [pvPairs {'SizeData',this.HGHandle.SizeData(~I)}];
end

% Remove from vector-valued CData
if size(this.HGHandle.CData,1)>1
    pvPairs = [pvPairs {'CData',this.HGHandle.CData(~I,:)}];
end

% Apply the changes
if ~isempty(pvPairs)
    set(this.HGHandle,pvPairs{:});
end