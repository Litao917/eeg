function notify(hndl, varargin)
%SCRIBEHANDLE/NOTIFY Notify method for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 


ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
MLObj = notify(MLObj, varargin{:});

ud.ObjectStore = MLObj;
setscribeobjectdata(hndl.HGHandle,ud);
