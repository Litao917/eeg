function A = copy(this,DataCopy)
%COPY  Copy method for @MATFileContainer.

%   Copyright 1986-2004 The MathWorks, Inc.

% RE: Never copy the file pointer (no obvious way to copy file-based data)
A = hds.MATFileContainer;