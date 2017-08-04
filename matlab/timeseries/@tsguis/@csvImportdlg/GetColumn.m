function tmpCell = GetColumn(h)
% GETCOLUMN returns a cell array with column letters for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2011 The MathWorks, Inc.


columnLength = size(h.IOData.rawdata,2);

% reset the h.IOData.checkLimitColumn
h.IOData.checkLimitColumn=20;
% if too many columns available, return column letters plus 'More'
if (columnLength>h.IOData.checkLimitColumn)
    tmpCell=cell(h.IOData.checkLimitColumn+1,1);
    for k=1:h.IOData.checkLimitColumn
        tmpCell(k)={h.findcolumnletter(k)};
    end
    tmpCell(h.IOData.checkLimitColumn+1)={getString(message('MATLAB:tsguis:csvImportdlg:GetColumn:More'))};
else
    tmpCell=cell(columnLength,1);
    for k=1:columnLength
        tmpCell(k)={h.findcolumnletter(k)};
    end
end


