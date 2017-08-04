function flag=initialize(h,filename)
% INITIALIZE is the function that tstool uses to display the import dialog
% given full path of the file in the 'filename' parameter.

% 1. the import dialog is resizable.
% 2. if the filename is the same as the last one, just display the import
%    dialog without reloading the file, otherwise, load the new file and
%    refresh the dialog.

% Author: Rong Chen 
%  Copyright 2004-2012 The MathWorks, Inc.

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
h.defaultPositions;

% -------------------------------------------------------------------------
%% check if the same file is to be opened 
% -------------------------------------------------------------------------
if strcmp(h.IOData.FileName,filename)
    if  ~isempty(h.Handles.tsTable)
       set(h.Handles.tsTablePanel,'Position',...
           [h.DefaultPos.Table_leftoffset ...
            h.DefaultPos.Table_bottomoffset+28 ...
            h.DefaultPos.Table_width ...
            h.DefaultPos.Table_height-28],...
            'Visible','on');
    end                            
    set(h.Handles.PNLdata,'Visible','on');
    set(h.Handles.PNLtime,'Visible','on');
    % update the dialog title
    set(h.Figure,'Name',getString(message('MATLAB:tsguis:excelImportdlg:initialize:ImportTimeSeriesFromExcel',filename)));
    flag=true;
    return
end

% update the filename
h.IOData.FileName=filename;

% -------------------------------------------------------------------------
%% Initialize the internal state variables
% -------------------------------------------------------------------------
% update the dialog title
set(h.Figure,'Name',getString(message('MATLAB:tsguis:excelImportdlg:initialize:ImportTimeSeriesFromExcel',filename)));

% initialize state variables
h.IOData.checkLimitColumn=20;
h.IOData.checkLimitRow=20;
h.IOData.checkLimit=20;
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

h.Handles.bar=waitbar(20/100,getString(message('MATLAB:tsguis:excelImportdlg:initialize:LoadingExcelPleaseWait')));

% -------------------------------------------------------------------------
%% Build data panel
% -------------------------------------------------------------------------
flag=h.initializeDataPanel(filename);
if ~flag
    h.IOData.FileName=[];
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
    delete(h.Handle.bar);
end


% -------------------------------------------------------------------------
%% show table
% -------------------------------------------------------------------------

set(h.Handles.tsTablePanel,'Position', ...
    [h.DefaultPos.Table_leftoffset ...
    h.DefaultPos.Table_bottomoffset+28 ...
    h.DefaultPos.Table_width ...
    h.DefaultPos.Table_height-28],'Visible','on');
set(h.Handles.PNLdata,'Visible','on');
set(h.Handles.PNLtime,'Visible','off');
strSelectedTimeVector = getString(message('MATLAB:tsguis:excelImportdlg:initialize:SelectedTimeVector'));
set(h.Handles.PNLDisplayWorkspaceInfo,'Title',sprintf(' %s ',strSelectedTimeVector));
set(h.Handles.PNLtime,'Visible','on');

% -------------------------------------------------------------------------
%% select all
% -------------------------------------------------------------------------
if ~isempty(h.Handles.tsTable)
    awtinvoke(h.Handles.tsTable.getTable,'selectAll');
end

