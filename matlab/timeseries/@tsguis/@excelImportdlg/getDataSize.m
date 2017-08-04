function rowLength = getDataSize(h,dim)

% Copyright 2006-2012 The MathWorks, Inc.

%% Get the number of columns for the current sheet
strCell = get(h.Handles.COMBdataSheet,'String');
tmpSheet = genvarname(strCell{get(h.Handles.COMBdataSheet,'Value')});
rowLength = size(h.IOData.rawdata.(tmpSheet),dim);
