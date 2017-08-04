function updateTableDisp(h) 
% UPDATETABLEDISPLAY is called when start/end time edit boxes are updated

% Author: Rong Chen 
% Revised: 
% Copyright 2005-2012 The MathWorks, Inc.

if ~isempty(h.Handles.tsTable)
    if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
        % change highlights
        awtinvoke(h.Handles.tsTable.getTable,'addRowSelectionInterval',h.IOData.SelectedRows(1)-1,h.IOData.SelectedRows(end)-1);
        awtinvoke(h.Handles.tsTable.getTable,'addColumnSelectionInterval',h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
        % change highlights in the uitable when editboxes are changed
        awtinvoke(h.Handles.tsTable.getTable,'scrollRectToVisible',h.Handles.tsTable.getTable.getCellRect(h.IOData.SelectedRows(end)-1,h.IOData.SelectedColumns(end)-1,true));
        h.Handles.tsTable.getTable.repaint;
    end
end

