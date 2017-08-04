function flag=ReadExcelFile(h,FileName) 
% READEXCELFILE populates the spreadsheet in the activex/uitable
% the input option should be either 'ActiveX' or 'uiTable'

% Author: Rong Chen 
%  Copyright 2004-2012 The MathWorks, Inc.

import javax.swing.*;

flag=true;
SheetNumber=length(h.IOData.DES);
if ishandle(h.Handle.bar)
   waitbar(40/100,h.Handle.bar);
end

if ~isempty(h.Handles.tsTable)
    % uitable is used to display excel sheet, which is read only
    % populate the sheet combo box 
    set(h.Handles.COMBdataSheet,'String',h.IOData.DES,'Value',1)
    % read all the sheets into the active workbook
    h.IOData.rawdata=struct();
    for k=1:SheetNumber
        % read data from an excel file whose name is supplied from outside
        swarn = warning('off','MATLAB:xlsread:Mode');
        try
            [~,~, rawdata] = xlsread(FileName,h.IOData.DES{k});
        catch %#ok<CTCH>
            errordlg(getString(message('MATLAB:tsguis:excelImportdlg:ReadExcelFile:NotValidExcelWorkbook')),...
                    getString(message('MATLAB:tsguis:excelImportdlg:ReadExcelFile:TimeSeriesTools')),'modal');
            delete(h.Handle.bar);
            flag=false;
            warning(swarn);
            return
        end
        warning(swarn);
        % save the size of each sheet
        tmpSize=size(rawdata);
        h.IOData.originalSheetSize(k,:)=tmpSize;
        if ishandle(h.Handle.bar)
           waitbar(40/100+(20/SheetNumber/100)*k,h.Handle.bar);
        end
        % in this case, since no number format data is available, it is
        % impossible to get the absolute time format anyway
        % replace NaN with '' for correct display in ActX
        % deal with the NaN issue in the rawdata
        if ~iscell(rawdata)
            % sheet contains a single data point or empty
            if ~ischar(rawdata) && isnan(rawdata)
                rawdata={''};
            end
        else
            % replace NaN with '' for correct display
            for i=1:tmpSize(1)
                for j=1:tmpSize(2)
                    if isnan(rawdata{i,j})
                        rawdata(i,j)={''};
                    end
                end
            end
        end
        % save the rawdata into memory
        h.IOData.rawdata.(genvarname(h.IOData.DES{k}))=rawdata;
        if ishandle(h.Handle.bar)
           waitbar(40/100+(40/SheetNumber/100)*k,h.Handle.bar);
        end
    end
    % populate the first sheet into the table
    set(h.Handles.tsTable,'NumRows',h.IOData.originalSheetSize(1,1));
    set(h.Handles.tsTable,'NumColumns',h.IOData.originalSheetSize(1,2));
    h.Handles.tsTable.setData(h.IOData.rawdata.(genvarname(h.IOData.DES{1})));
    set(h.Handles.tsTable,'Editable',false);
    javaMethodEDT('setRowSelectionAllowed',h.Handles.tsTable.getTable,true);
    javaMethodEDT('setColumnSelectionAllowed',h.Handles.tsTable.getTable,true);
    awtinvoke(h.Handles.tsTable.getTable,'clearSelection');
end

