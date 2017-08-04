function this = MATFileContainer(FileName)
% Defines properties for @MATFileContainer class
% (implements @ArrayContainer interface)

%   Copyright 1986-2004 The MathWorks, Inc.
this = hds.MATFileContainer;
this.FileName = FileName;
