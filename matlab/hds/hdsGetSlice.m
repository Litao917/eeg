function A = hdsGetSlice(A,Section)
%HDSGETSLICE  Extracts array slice.

%   Copyright 1986-2004 The MathWorks, Inc.
A = A(Section{:});