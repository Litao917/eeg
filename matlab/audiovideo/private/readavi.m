function moviedata = readavi(varargin)
%READAVI read frames from AVI file
%   MOVIEDATA = readavi(FILENAME,INDEX) reads from the AVI file FILENAME.  If
%   INDEX is -1, all frames in the movie are read. Otherwise, only frame number
%   INDEX is read.  READAVI returns a MATLAB structure MOVIEDATA with 
%   fields cdata and colormap.  cdata contains frame data that must be rotated 
%   and reshaped.  colormap contains the colormap if the frame is an Indexed 
%   image.  colormap must also be adjusted to the correct size.

%   Copyright 1984-2013 The MathWorks, Inc.
%#mex

error('MATLAB:audiovideo:readavi:missingmex',sprintf('Missing MEX-file %s.',mfilename));

