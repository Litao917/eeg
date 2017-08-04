function A = hdsSetSlice(A,Section,B)
%HDSSETSLICE  Modifies array slice.

%   Copyright 1986-2004 The MathWorks, Inc.
A(Section{:}) = B;