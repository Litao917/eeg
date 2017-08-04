function undo(h)
%UNDO  Undo transaction.
% Tsc is a handle to the tscollection object on which the undo operation
% needs to apply.

%   Copyright 2005-2012 The MathWorks, Inc.

objectlist = h.ObjectsCell;
parentNode = h.ParentNodeHandle;

if isempty(parentNode)
    disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:TheParentNodeSuppliedForUndoIsInvalid')));
    return;
end

if iscell(objectlist)
    if ~isempty(objectlist)
        if strcmpi(h.Action,'renamed')
            parentNode.restoreDataNode(objectlist,h.Action,h.NamePair{1});
        else
            parentNode.restoreDataNode(objectlist,h.Action);
        end
    else
        disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:ObjectListCellArrayIsEmptyCannotUndo')))
    end
else
    disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:ACellArrayOfDataObjectsExpectedUndoAborted')))
end
