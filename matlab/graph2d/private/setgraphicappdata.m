function setgraphicappdata(h,fieldname,value)
% This undocumented function may be removed in a future release.

%   Copyright 2008 The MathWorks, Inc.


if graphicsversion(h,'handlegraphics')==1
    setappdata(h,fieldname,value);
else
    % For MCOS make sure that graphic app data is stored as an object not 
    % as a double
    setappdata(h,fieldname,handle(value));
end