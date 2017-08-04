function selectedData = getSelectedDataFromVariableEditor(ts,rowSelection,columnSelection)
% This undocumented function may be removed in a future release.

% Copyright 2012 The MathWorks, Inc.

% Create an array combining time vector and 2-d data array 
if ~isempty(ts.TimeInfo.StartDate)
    combinedTimeDataArray = [ts.getabstime  num2cell(ts.Data)];
else
    combinedTimeDataArray = [ts.Time ts.Data];
end

% Index into the combined array
if nargin<=1
    selectedData = combinedTimeDataArray;
else
    selectedData = combinedTimeDataArray(rowSelection,columnSelection);
end