function redo(h)
%REDO  Redoes transaction.

%   Copyright 2005-2012 The MathWorks, Inc.

objectlist = h.ObjectsCell;
parentNode = h.ParentNodeHandle;

switch h.Action
    case 'added'
        myAction = 'removed';
    case 'removed'
        myAction = 'added';
    case 'renamed'
        myAction = 'renamed';
end
        
if isempty(parentNode)
    disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:TheParentNodeSuppliedForRedoIsInvalid')));
    return;
end

if iscell(objectlist)
    if ~isempty(objectlist)
        if strcmpi(h.Action,'renamed')
            parentNode.restoreDataNode(objectlist,myAction,h.NamePair{2});
        else
            parentNode.restoreDataNode(objectlist,myAction);
        end
    else
        disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:ObjectListCellArrayIsEmptyCannotRedo')))
    end
else
    disp(getString(message('MATLAB:timeseries:tsguis:nodetransaction:ACellArrayOfDataObjectsExpectedRedoAborted')))
end

