function updateTableDisp(h,scrollToSelectionFlag) 

% Copyright 2005-2010 The MathWorks, Inc.

if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    if nargin<=1
        scrollToSelectionFlag = true;
    end
    
    % Change highlights
    h.Handles.tsTable.setSelectionIntervalNoCallback(h.IOData.SelectedRows(1)-1,...
        h.IOData.SelectedRows(end)-1);
    awtinvoke(h.Handles.tsTable,'setColumnSelectionInterval',...
        h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
    
    % Scroll to the last selected cell if the selection is the result of
    % modifying an edit box.
    if scrollToSelectionFlag
        awtinvoke(h.Handles.tsTable,'scrollRectToVisible',...
            h.Handles.tsTable.getCellRect(h.IOData.SelectedRows(end)-1,...
            h.IOData.SelectedColumns(end)-1,true));
    end
end