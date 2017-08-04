function h = tstreeevent(hSrc,action,node)
%DATAEVENT  Subclass of EVENTDATA to handle tree structure changes

%   Author(s): 
%   Copyright 1986-2005 The MathWorks, Inc.


% Create class instance
h = tsexplorer.tstreeevent(hSrc,'tsstructurechange');
set(h,'Action',action,'Node',node)
