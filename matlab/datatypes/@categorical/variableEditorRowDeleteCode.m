function [out,warnmsg] = variableEditorRowDeleteCode(~,varName,rowIntervals)
%   This function is undocumented and will change in a future release

% Generate MATLAB command to delete rows in positions defined
% by the 2-column rowIntervals matrix. It is assumed that row intervals
% are disjoint, in monotonic order, and bounded by the number of rows 
% in the categorical array.

%   Copyright 2013 The MathWorks, Inc.

warnmsg = '';

if size(rowIntervals,1)==1
    out = sprintf('%s(%s,:) = [];',varName,localBuildSubsref(rowIntervals(1),rowIntervals(2)));
else
    rowSubsref = localBuildSubsref(rowIntervals(1,1),rowIntervals(1,2));
    for row=2:size(rowIntervals,2)
        rowSubsref = sprintf('%s,%s',rowSubsref,localBuildSubsref(rowIntervals(row,1),rowIntervals(row,2)));
    end
    out = sprintf('%s([%s],:) = [];',varName,rowSubsref); % e.g. x([1:2 5],:) = [];
end

function subsrefexp = localBuildSubsref(startRow,endRow)

% Create a sub-index expression for the interval startCol:endCol
if startRow==endRow
    subsrefexp = sprintf('%d',startRow);
else
    subsrefexp = sprintf('%d:%d',startRow,endRow);
end