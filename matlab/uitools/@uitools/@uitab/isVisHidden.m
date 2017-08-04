function res = isVisHidden(this)
%Helper method for uitab

%   Copyright 2004 The MathWorks, Inc.
res = ~(this.OKToModifyVis);
