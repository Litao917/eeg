function tmpCell = GetRow(h)
% GETROW returns a cell array with row numbers 

%  Copyright 2004-2011 The MathWorks, Inc.
 

rowLength = size(h.IOData.rawdata,1);

% reset the h.IOData.checkLimitColumn
h.IOData.checkLimitRow=20;
% if too many rows available, return row numbers plus 'More'
if (rowLength>h.IOData.checkLimitRow)
    % too many rows, put getString(message('MATLAB:tsguis:csvImportdlg:GetRow:More')) option at the end of the list
    tmpCell=num2cell(1:h.IOData.checkLimitRow);
    tmpCell(h.IOData.checkLimitRow+1)={getString(message('MATLAB:tsguis:csvImportdlg:GetRow:More'))};
else
    tmpCell=num2cell(1:rowLength);
end


