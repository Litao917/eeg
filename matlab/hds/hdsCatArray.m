function A = hdsCatArray(dim,varargin)
%HDSCATARRAY  Horizontal or vertical array concatenation.

%   Copyright 1986-2004 The MathWorks, Inc.
A = cat(dim,varargin{:});