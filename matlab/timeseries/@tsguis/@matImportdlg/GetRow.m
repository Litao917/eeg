function tmpCell = GetRow(h)
% GETROW returns a cell array with row numbers for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2011 The MathWorks, Inc.
 
% check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    rowLength=h.IOData.SelectedVariableInfo.objsize(1);
    % reset the h.IOData.checkLimitColumn
    h.IOData.checkLimitRow=20;
    % if too many rows available, return row numbers plus 'More'
    if (rowLength>h.IOData.checkLimitRow)
        % too many rows, put getString(message('MATLAB:tsguis:matImportdlg:GetRow:More')) option at the end of the list
        tmpCell=num2cell(1:h.IOData.checkLimitRow);
        tmpCell(h.IOData.checkLimitRow+1)={getString(message('MATLAB:tsguis:matImportdlg:GetRow:More'))};
    else
        tmpCell=num2cell(1:rowLength);
    end
else
    tmpCell={' '};
end


