function flag = initialize(h,filename)
% INITIALIZE is the function that tstool uses to display the import dialog
% given full path of the file in the 'filename' parameter.

% 1. the import dialog is resizable.
% 2. if the filename is the same as the last one, just display the import
%    dialog without reloading the file, otherwise, load the new file and
%    refresh the dialog.

%  Copyright 2004-2011 The MathWorks, Inc.

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
h.defaultPositions;

% -------------------------------------------------------------------------
%% check if the same file is to be opened 
% -------------------------------------------------------------------------
if strcmp(h.IOData.FileName,filename)
    % the input filename is the same as h.IOData.ExcelFileName
    if  ~isempty(h.Handles.tsTable)
       set(h.Handles.tsTablePanel,'Visible','on')
    end                            
    set(h.Handles.PNLdata,'Visible','on');
    set(h.Handles.PNLtime,'Visible','on');
    % update the dialog title
    set(h.Figure,'Name',getString(message('MATLAB:tsguis:csvImportdlg:initialize:ImportTimeSeriesFromTextFile',filename)));
    flag=true;
    return
end

% update the filename
h.IOData.FileName = filename;

% -------------------------------------------------------------------------
%% Initialize the internal state variables
% -------------------------------------------------------------------------
% update the dialog title
set(h.Figure,'Name',getString(message('MATLAB:tsguis:csvImportdlg:initialize:ImportTimeSeriesFromTextFile',filename)));

% initialize state variables
h.IOData.checkLimitColumn=20;
h.IOData.checkLimitRow=20;
% no selection
h.IOData.SelectedColumns=[];
h.IOData.SelectedRows=[];
% no format information
h.IOData.formatcell=struct();
h.IOData.formatcell.name='';
h.IOData.formatcell.columnIndex=0;
h.IOData.formatcell.rowIndex=0;
h.IOData.formatcell.matlabFormatString = ...
    {'dd-mmm-yyyy HH:MM:SS' 'dd-mmm-yyyy' 'mm/dd/yy' 'mm/dd' 'HH:MM:SS' ...
    'HH:MM:SS PM' 'HH:MM' 'HH:MM PM' 'mmm.dd,yyyy HH:MM:SS' 'mmm.dd,yyyy' 'mm/dd/yyyy' 'custom'};
h.IOData.formatcell.matlabFormatIndex = [0 1 2 6 13 14 15 16 21 22 23 inf];
h.IOData.formatcell.matlabUnitString={'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'};

h.Handles.bar = waitbar(20/100,getString(message('MATLAB:tsguis:csvImportdlg:initialize:LoadingTextFilePleaseWait')));

% -------------------------------------------------------------------------
%% Build data panel
% -------------------------------------------------------------------------
flag = h.initializeDataPanel(filename);
if ~flag
    h.IOData.FileName = [];
    return
end
if ishandle(h.Handle.bar)
    waitbar(90/100,h.Handle.bar);
end

% -------------------------------------------------------------------------
%% Build time panel
% -------------------------------------------------------------------------
h.initializeTimePanel;
if ishandle(h.Handle.bar)
    waitbar(100/100,h.Handle.bar);
end
delete(h.Handle.bar);

% -------------------------------------------------------------------------
%% show table
% -------------------------------------------------------------------------
set(h.Handles.tsTablePanel,'Position', ...
    [h.DefaultPos.Table_leftoffset ...
    h.DefaultPos.Table_bottomoffset+28 ...
    h.DefaultPos.Table_width ...
    max(h.DefaultPos.Table_height-28,5)],...
    'Visible','on');
set(h.Handles.PNLdata,'Visible','on');
set(h.Handles.PNLtime,'Visible','off');
strSelectedTimeVector = getString(message('MATLAB:tsguis:csvImportdlg:initialize:SelectedTimeVector'));
set(h.Handles.PNLDisplayWorkspaceInfo,'Title',sprintf(' %s ',strSelectedTimeVector));
set(h.Handles.PNLtime,'Visible','on');


% -------------------------------------------------------------------------
%% check date string format
% -------------------------------------------------------------------------
% get numberformat property for the first column and the first row,
% and the information is stored in the 'formatcell' struct.
% Note: only a limited number of cells are checked for absolute
% date/time format, or the relative time format
% check only on the active sheet when exits
h.checkTimeFormat('both','1');

if h.IOData.formatcell.columnIsAbsTime>=0
    % the first column contains absolute time format
    set(h.Handles.COMBdataSample,'Value',1);
    h.TimePanelUpdate('column');
elseif h.IOData.formatcell.rowIsAbsTime>=0
    % the first row contains absolute time format
    set(h.Handles.COMBdataSample,'Value',2);
    h.TimePanelUpdate('row');
elseif h.IOData.formatcell.columnIsAbsTime==-1
    % the first column contains doubles which can be relative time
    set(h.Handles.COMBdataSample,'Value',1);
    h.TimePanelUpdate('column');
elseif h.IOData.formatcell.rowIsAbsTime==-1
    % the row column contains doubles which can be relative time
    set(h.Handles.COMBdataSample,'Value',2);
    h.TimePanelUpdate('row');
else 
    % no time or number detected in either the first row or column
    % set column as default and bring up the manual input
    set(h.Handles.COMBdataSample,'Value',1);
    h.TimePanelUpdate('column');
    set(h.Handles.COMBtimeSource,'Value',2);
    set(h.Handles.PNLtimeCurrentSheet,'Visible','off');
    set(h.Handles.PNLtimeManual,'Visible','on');
end        

    
% -------------------------------------------------------------------------
%% select all
% -------------------------------------------------------------------------
if ~isempty(h.Handles.tsTable)
    h.selectionChanged(0:h.Handles.tsTable.getRowCount-1,...
        0:h.Handles.tsTable.getColumnCount-1,false);
end

