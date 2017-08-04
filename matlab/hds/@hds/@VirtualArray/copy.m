function A = copy(this,DataCopy)
%COPY  Copy method for @VirtualArray.

%   Copyright 1986-2004 The MathWorks, Inc.
A = hds.VirtualArray;
A.GridFirst = this.GridFirst;
A.SampleSize = this.SampleSize;
A.Variable = this.Variable;
A.MetaData = copy(this.MetaData);
if ~isempty(this.Storage)
   A.Storage = copy(this.Storage,DataCopy);
end
