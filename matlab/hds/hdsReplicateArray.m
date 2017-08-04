function a = hdsReplicateArray(a,Pattern)
%HDSREPLICATE  Replicates data point array along grid dimensions.

%   Copyright 1986-2004 The MathWorks, Inc.
a = repmat(a,Pattern);