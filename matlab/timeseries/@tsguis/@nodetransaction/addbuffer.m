function addbuffer(T,str,varargin)

%   Copyright 2005 The MathWorks, Inc.

%% Add a new M recorder string to the buffer
T.Buffer = [T.Buffer; {str}];
