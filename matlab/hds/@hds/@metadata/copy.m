function h = copy(this)
%COPY  Copy for metadata objects

%   Copyright 1986-2005 The MathWorks, Inc.
h = hds.metadata;
h.Units = this.Units;