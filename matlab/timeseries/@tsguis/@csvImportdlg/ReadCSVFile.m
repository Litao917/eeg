function flag = ReadCSVFile(h,FileName) 
% READEXCELFILE populates the spreadsheet in the activex/uitable
% the input option should be either 'ActiveX' or 'uiTable'

% Author: Rong Chen 
%  Copyright 2005-2011 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;


flag = true;
if ishandle(h.Handle.bar)
   waitbar(40/100,h.Handle.bar);
end

% Read data from an csv file whose name is supplied from outside
try
    [dataStruct,~,headerlines] = importdata(FileName);
    if isstruct(dataStruct)
        thisData = cell(size(dataStruct.data,1)+headerlines,size(dataStruct.data,2));
        if isfield(dataStruct,'textdata')
            thisData(1:size(dataStruct.textdata,1),1:size(dataStruct.textdata,2)) =...
                dataStruct.textdata;
        end 
        thisData(headerlines+1:end,end-size(dataStruct.data,2)+1:end) = ...
            num2cell(dataStruct.data);   
    elseif isnumeric(dataStruct)
        thisData = num2cell(dataStruct);
    elseif iscell(dataStruct)
        thisData = dataStruct;
    else
        error(message('MATLAB:tsguis:csvImportdlg:ReadCSVFile:invFile'));
    end
catch %#ok<CTCH>
    errordlg(getString(message('MATLAB:tsguis:csvImportdlg:ReadCSVFile:IsNotAValidTextFile')),getString(message('MATLAB:tsguis:csvImportdlg:ReadCSVFile:TimeSeriesTools')),...
        'modal');
    delete(h.Handle.bar);
    flag = false;
    return
end

% Save the size of each sheet
tmpSize = size(thisData);
h.IOData.originalSheetSize = tmpSize;
h.IOData.currentSheetSize = tmpSize;
if ishandle(h.Handle.bar)
    waitbar(.6,h.Handle.bar);
end
% Save the rawdata into memory
h.IOData.rawdata = thisData;
if ishandle(h.Handle.bar)
   waitbar(.8,h.Handle.bar);
end
% Create the table
columnLetters = cell(1,size(h.IOData.rawdata,2));
for k=1:length(columnLetters)
     columnLetters{k} = h.findcolumnletter(k);
end
h.Handles.tsTable = javaObjectEDT('com.mathworks.toolbox.timeseries.ImportTable',...
    h,columnLetters,size(h.IOData.rawdata,1),size(h.IOData.rawdata,2));



