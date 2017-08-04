function tmpCell = GetColumn(h)
% GETCOLUMN returns a cell array with column letters for active spreadsheet

%  Copyright 2004-2011 The MathWorks, Inc.

% Check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    columnLength = h.IOData.SelectedVariableInfo.objsize(2);
    % Reset the h.IOData.checkLimitColumn
    h.IOData.checkLimitColumn = 20;
    % If too many columns available, return column letters plus 'More'
    if (columnLength>h.IOData.checkLimitColumn)
        tmpCell = num2cell(1:h.IOData.checkLimitColumn);
        tmpCell(h.IOData.checkLimitColumn+1)={getString(message('MATLAB:tsguis:matImportdlg:GetColumn:More'))};
    else
        tmpCell = num2cell(1:columnLength);
    end
else
    tmpCell = {' '};
end

