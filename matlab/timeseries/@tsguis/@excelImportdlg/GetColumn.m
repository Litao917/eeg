function tmpCell = GetColumn(h)
% GETCOLUMN returns a cell array with column letters for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2012 The MathWorks, Inc.

% check platform
% uitable is used
strCell=get(h.Handles.COMBdataSheet,'String');
tmpSheet=genvarname(strCell{get(h.Handles.COMBdataSheet,'Value')});
columnLength=size(h.IOData.rawdata.(tmpSheet),2);

% reset the h.IOData.checkLimitColumn
h.IOData.checkLimitColumn=20;
% if too many columns available, return column letters plus 'More'
if (columnLength>h.IOData.checkLimitColumn)
    tmpCell=cell(h.IOData.checkLimitColumn+1,1);
    for k=1:h.IOData.checkLimitColumn
        tmpCell(k)={h.findcolumnletter(k)};
    end
    tmpCell(h.IOData.checkLimitColumn+1)={getString(message('MATLAB:tsguis:excelImportdlg:GetColumn:More'))};
else
    tmpCell=cell(columnLength,1);
    for k=1:columnLength
        tmpCell(k)={h.findcolumnletter(k)};
    end
end


