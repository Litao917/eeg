function A = copy(this,DataCopy)
%COPY  Copy method for @BasicArray.

%   Copyright 1986-2004 The MathWorks, Inc.
A = hds.BasicArray;
A.GridFirst = this.GridFirst;
A.SampleSize = this.SampleSize;
A.Variable = this.Variable;
A.MetaData = copy(this.MetaData);
if DataCopy
   A.Data = this.Data;
end