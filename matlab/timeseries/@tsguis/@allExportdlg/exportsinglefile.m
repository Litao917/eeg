function exportsinglefile(h,tsfigure,tsnodes)
% EXPORTSINGLEFILE  Export a cell array of time series objects (timeseries,
% tscollections) to a single MS Excel workbook.  Each individual timeseries
% object will be saved into a separated spreadsheet.
%
% tsfigure: handle to the main tstool figure window
% tsnodes: a cell array of nodes which contains time series objects
%

%  Author(s): Rong Chen
%  Copyright 2004-2012 The MathWorks, Inc.

import javax.swing.*

%% Bring up file chooser and allow user to select either XLS or MAT
% configure filechooser
chooser = javaObjectEDT('com.mathworks.mwswing.MJFileChooserPerPlatform');
% setup file filter to valid export file types
if ispc
    filter=javaObjectEDT('com.mathworks.mwswing.FileExtensionFilter',getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:ExcelWorkbook')), {'xls', 'xlsx'}, true, false);
    javaMethodEDT('addChoosableFileFilter',chooser,filter);
end
filter = javaObjectEDT('com.mathworks.mwswing.FileExtensionFilter', getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:MATFile')), {'mat'}, true);
javaMethodEDT('addChoosableFileFilter',chooser,filter);
javaMethodEDT('setAcceptAllFileFilterUsed',chooser,false);
% show the filechooser
jf=tsguis.getJavaFrame(tsfigure);
jframe = SwingUtilities.getWindowAncestor(jf.getAxisComponent);
javaMethodEDT('showSaveDialog',chooser,jframe);
returnVal=javaMethodEDT('getState',chooser);
returnExt=get(chooser,'FileFilter');

% if no valid file is chosen, exit
if returnVal~=javax.swing.JFileChooser.APPROVE_OPTION
    return
% otherwise, get file information
else
    selectedFile = javaMethodEDT('getSelectedFile', chooser);
    filefullname=(selectedFile.toString.toCharArray)';
    [filePath,fileName,fileExtension] = fileparts(filefullname);
    if isempty(fileExtension) 
        if ~returnExt.getPlainExtension.isEmpty
            fileExtension = ['.' char(returnExt.getPlainExtension.get(0))];
        else
            fileExtension = '';
        end
    end
    filefullname=fullfile(filePath,[fileName fileExtension]);    
end
    
%% branch start here: xls, mat and csv/txt in the future
% export to an excel file
if strcmpi(fileExtension,'.xls') || strcmpi(fileExtension,'.xlsx')
    % initialize a waitbar
    bar = waitbar(10/100,getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:ExportingTimeSeriesObjectsPleaseWait')),'WindowStyle','modal');
    % get excel workbook information if not new
    if ~isempty(dir(filefullname))
        try
            [FileInfo,SavedNames]=xlsfinfo(filefullname);
        catch %#ok<*CTCH>
            localInvalidExcel(bar);
            return
        end
        % check if the file is valid
        if isempty(FileInfo)
            localInvalidExcel(bar)
            return
        end
    end    
    if ishandle(bar)
       waitbar(20/100,bar);
    end
    % use a loop to export all the objects
    for i=1:length(tsnodes)
        % get each time series object in the cell array
        if isa(tsnodes{i},'tsguis.tsnode')            
            ts = tsnodes{i}.Timeseries;
            if isempty(dir(filefullname))
                SavedNames = utExportTS(h,ts,filefullname,true,{},bar,i/length(tsnodes)*0.7+0.2);
                if isempty(SavedNames)
                    return
                else
                    SavedNames = {SavedNames};
                end
            else
                name = utExportTS(h,ts,filefullname,false,SavedNames,bar,i/length(tsnodes)*0.7+0.2);
                if isempty(name)
                    return
                end
                SavedNames(end+1)={name}; %#ok<AGROW>
            end
        elseif isa(tsnodes{i},'tsguis.tscollectionNode')            
            tsc = tsnodes{i}.Tscollection.TsValue;
            names = gettimeseriesnames(tsc);
            for j=1:length(names)
                if isempty(dir(filefullname))
                    SavedNames = utExportTS(h,tsc.(names{j}),filefullname,true,{},bar,i/length(tsnodes)*0.7+0.2);
                    if isempty(SavedNames)
                        return
                    else
                        SavedNames = {SavedNames};
                    end
                else
                    name = utExportTS(h,tsc.(names{j}),filefullname,false,SavedNames,bar,i/length(tsnodes)*0.7+0.2);
                    if isempty(name)
                        return
                    end
                    SavedNames(end+1)={name}; %#ok<AGROW>
                end
            end
        end
    end
    delete(bar);
    % show excel file
    if ispc
        try
            if ispc
                winopen(filefullname);
            else
                eval(['!' filefullname ' &']);
            end
        catch
            % do nothing
        end
    end
elseif strcmpi(fileExtension,'.txt')
elseif strcmpi(fileExtension,'.mat')
    % Export to an mat file
    % Initialize a waitbar
    bar  = waitbar(20/100,getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:ExportingTimeSeriesObjectsPleaseWait')),'WindowStyle','modal');
    % Use a loop to export all the objects
    for i=1:length(tsnodes)
        % get each time series object in the cell array
        if isa(tsnodes{i},'tsguis.tsnode')            
            localSaveToMatFile(filefullname,timeseries(tsnodes{i}.Timeseries));
        elseif isa(tsnodes{i},'tsguis.tscollectionNode') 
            localSaveToMatFile(filefullname,tscollection(tsnodes{i}.Tscollection));
        end
        if ishandle(bar)
            waitbar(i/length(tsnodes)*0.7+0.2,bar);
        end
    end
    delete(bar);
elseif ~isempty(fileExtension) && strcmpi(fileExtension,'.csv')
else
end

    
function localInvalidExcel(bar)

errordlg(getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:InvalidExcelWorkbook')),getString(message('MATLAB:tsguis:allExportdlg:exportsinglefile:TimeSeriesTools')),'modal');
delete(bar);

function localSaveToMatFile(fileName_,tsObj_)

% Save or append the tscollection or timeseries object, tsObj, to the MAT
% file fileName_, avoiding any name conflicts
reservedNames = {'locVarName_';'fileName_';'tsObj_'};
if ~isempty(dir(fileName_))
    locVarName_ = genvarname(tsObj_.Name,[reservedNames;who('-file',fileName_)]);
else
    locVarName_ = genvarname(tsObj_.Name,reservedNames);
end
eval([locVarName_ '= tsObj_;']);
try
    if isempty(dir(fileName_))
        save(fileName_,locVarName_);
    else
        save(fileName_,locVarName_,'-append');
    end
catch me
    % If the save operation errors because the file cannot be written,
    % show the error message in an errordlg
    if strcmp('MATLAB:save:permissionDenied',me.identifier) || ...
         strcmp('MATLAB:save:couldNotWriteFile',me.identifier)   
        errordlg(me.message,'','modal')
    end
end

