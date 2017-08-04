function flag=initializeDataPanel(h, FileName)
% INITIALIZEDATAPANEL initializes the 'Select Data to Import' panel, which
% contains a uitable for spreadsheet display,
% as well as a few other uicontrols

% Author: Rong Chen 
%  Copyright 2004-2012 The MathWorks, Inc.

% -------------------------------------------------------------------------
%% Build data panel
%
% Note that: currently we only support single block data selection from the
% excel sheet.  The reason is that: 1. the mouse operation provided by the
% activex control only allows to select a single block; 2. the absolute
% time format results in a very complicated parser for the edit boxes if
% multiple blocks are allowed.  So, if user has discontinuous blocks, he
% can either merge them in excel before importing or create multiple
% timeseries during the import stage and then merge them later in tstool.
% -------------------------------------------------------------------------
h.DefaultPos.DataPanelDefaultColor=h.DefaultPos.FigureDefaultColor;
if isfield(h.Handles,'PNLdata') && ishghandle(h.Handles.PNLdata)
    delete(h.Handles.PNLdata);
end
strSpecifyData = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:SpecifyData'));
h.Handles.PNLdata = uipanel('Parent',h.Figure, ...
    'Units','Pixels', ...
    'FontSize',9,...
    'FontWeight','bold', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor,...
    'Position', [h.DefaultPos.leftoffsetpnl ...
                 h.DefaultPos.bottomoffsetDatapnl ...
                 h.DefaultPos.widthpnl ...
                 h.DefaultPos.heightDatapnl], ...
    'Title',sprintf(' %s ',strSpecifyData),...
    'Visible','off'...
);
% h.Handles.PNLdata = handle(h.Handles.PNLdata);

% -------------------------------------------------------------------------
%% display spreadsheet 
% -------------------------------------------------------------------------

% uitable is created instead
%%%% This call works with the undocumented version of uitable which
%%%% can be found in uitools\private\uitable_deprecated.m.  This
%%%% functionality will be removed in a future release.  
%%%%
%%%% To migrate to the supported uitable, use the following call:
%%%%   h.Handles.ts.Table = uitable(h.Figure);
%%%%
%%%% Note that the container h.Handles.ts.TablePanel is no longer
%%%% available.
if isfield(h.Handles,'tsTable') && ~isempty(h.Handles.tsTable) && ...
        ishandle(h.Handles.tsTable)
    set(handle(h.Handles.tsTable.getTable.getSelectionModel,'callbackproperties'),'ValueChangedCallback',[]);
    set(handle(h.Handles.tsTable.getTable.getColumnModel.getSelectionModel,'callbackproperties'),'ValueChangedCallback',[]);
    delete(h.Handles.tsTable);
end
if isfield(h.Handles,'tsTablePanel') && ~isempty(h.Handles.tsTablePanel) && ...
        ishandle(h.Handles.tsTablePanel)
    delete(h.Handles.tsTablePanel);
end
[h.Handles.tsTable, h.Handles.tsTablePanel] = uitable('v0', h.Figure);

%%%% The container is no longer available, but these properties can be
%%%% set on the table directly:
%%%%  set(h.Handles.tsTable,'Units','Pixels','Position', ...
%%%%     [0 0 1 1], ...
%%%%     'BackgroundColor',h.DefaultPos.DataPanelDefaultColor);
set(h.Handles.tsTablePanel,'Units','Pixels','Position', ...
    [0 0 1 1], ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor);
% Set java name for table
h.Handles.tsTable.getTable.setName('ImportDlgTSTable');

% set(h.Handles.tsTable.TableScrollPane,'Background',h.DefaultPos.DataPanelDefaultColor);
% prevent reordering the column
%%%% This statement is currently not migratable.
%h.Handles.tsTable.getTable.getTableHeader().setReorderingAllowed(false);
javaMethodEDT('setReorderingAllowed',h.Handles.tsTable.getTable.getTableHeader,false)
% create time unit popupmenu control
strSheet = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:Sheet'));
h.Handles.TXTdataSheet = uicontrol('Parent',h.Handles.PNLdata,...
    'style','text',...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor,...
    'String',sprintf('%s :',strSheet),...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.TXTdataSampleleftoffset 80-4 h.DefaultPos.TXTdataSamplewidth h.DefaultPos.heighttxt] ...
    );
h.Handles.COMBdataSheet = uicontrol('Parent',h.Handles.PNLdata,...
    'style','popupmenu',...
    'Units','Pixels',...
    'String',' ',...
    'Value',1,...
    'Position',[h.DefaultPos.COMBdataSampleleftoffset 80 h.DefaultPos.COMBdataSamplewidth h.DefaultPos.heightcomb], ...
    'Callback',{@localUITableSheetChanged h},...
    'Tag', 'COMBdataSheet');
if ~ismac
   set(h.Handles.COMBdataSheet,'BackgroundColor',[1 1 1]);
end


if ~isempty(h.Handles.tsTable)
    % populate the uitable using the data from the import file
    flag=h.ReadExcelFile(FileName);
    if ~flag
        return
    end    
    % use the active sheet name as the default time series object name
    strCell=get(h.Handles.COMBdataSheet,'String');
    set(h.Parent.Handles.EDTsingleNEW,'String',strCell{get(h.Handles.COMBdataSheet,'Value')});
    
    % register callback
    
    %%%% These statements are currently not migratable.
    set(handle(h.Handles.tsTable.getTable.getSelectionModel,'callbackproperties'),'ValueChangedCallback',{@localUITableDataChanged h});
    set(handle(h.Handles.tsTable.getTable.getColumnModel.getSelectionModel,'callbackproperties'),'ValueChangedCallback',{@localUITableDataChanged h});
else
    errordlg(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:CannotCreateTimeSeriesData')),...
        getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')),'modal');
    delete(h.Handle.bar);
    flag=false;
    return;
end

% -------------------------------------------------------------------------
%% create all the other ui controls in the data panel
% -------------------------------------------------------------------------
% add column and row edit boxes, static texts and radio buttons
huicTXTdataSample = uicontextmenu('Parent',h.Figure);
strDataArrangedBy = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:DataArrangedBy'));
h.Handles.TXTdataSample = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',sprintf('%s : ',strDataArrangedBy), ...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTdataSample,...
    'Position',[h.DefaultPos.TXTdataSampleleftoffset ...
                h.DefaultPos.TXTdataSamplebottomoffset ...
                h.DefaultPos.TXTdataSamplewidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTdataSample,'Label',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:WhatsThisLabel')),'Callback','tsDispatchHelp(''its_wiz_data_arranged_by'',''modal'')')

h.Handles.COMBdataSample = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','popupmenu', ...
    'Units','Pixels', ...
    'String',[{getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:Columns'))},{getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:Rows'))}], ...
    'Value',1,...
    'TooltipString',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:DataInCurrentVariableIsOrganized')), ...
    'Position',[h.DefaultPos.COMBdataSampleleftoffset ...
                h.DefaultPos.TXTdataSamplebottomoffset+4 ...
                h.DefaultPos.COMBdataSamplewidth ...
                h.DefaultPos.heightcomb], ...
    'Callback',{@localSwitchSample h}, ...
    'Tag', 'COMBdataSample');
if ~ismac
    set(h.Handles.COMBdataSample,'BackgroundColor',[1 1 1]);
end

huicTXTblock = uicontextmenu('Parent',h.Figure);
strDataBlockDefinedBy = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:DataBlockDefinedBy'));
h.Handles.TXTblock = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',sprintf('%s : ',strDataBlockDefinedBy), ...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTblock,...
    'Position',[h.DefaultPos.TXTdataleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTdatawidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTblock,'Label',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:WhatsThisLabel')),'Callback','tsDispatchHelp(''its_wiz_select_data_xls'',''modal'')')

h.Handles.TXTFROM = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TopleftCell')), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTfromleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTfromwidth ...
                h.DefaultPos.heighttxt] ...
    );

h.Handles.EDTFROM = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','edit', ...
    'Units','Pixels', ...
    'BackgroundColor',[1 1 1],...
    'String','', ...
    'TooltipString',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:KeyInTTopleftCorner')), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.EDTfromleftoffset ...
                h.DefaultPos.TXTdatabottomoffset+2 ...
                h.DefaultPos.EDTfromwidth ...
                h.DefaultPos.heightedt],...
    'Callback',{@localChangeBlock h 'FROM'}, ...
    'Tag', 'EDTFROM');

h.Handles.TXTTO = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',h.DefaultPos.DataPanelDefaultColor, ...
    'String',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:BottomrightCell')), ...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTtoleftoffset ...
                h.DefaultPos.TXTdatabottomoffset ...
                h.DefaultPos.TXTtowidth ...
                h.DefaultPos.heighttxt] ...
    );
h.Handles.EDTTO = uicontrol('Parent',h.Handles.PNLdata, ...
    'style','edit', ...
    'Units','Pixels', ...
    'BackgroundColor',[1 1 1],...
    'String','',...
    'TooltipString',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:KeyInBottomrightCorner')), ...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtoleftoffset ...
                h.DefaultPos.TXTdatabottomoffset+2 ...
                h.DefaultPos.EDTtowidth ...
                h.DefaultPos.heightedt],...
    'Callback',{@localChangeBlock h 'TO'}, ...
    'Tag', 'EDTTO');

% -------------------------------------------------------------------------
%% common callbacks
% -------------------------------------------------------------------------
function localSwitchSample(~,~, h)
% callback for COMBdataSample (Switch : a sample is a row or a column)
% change some disaply
if get(h.Handles.COMBdataSample,'Value')==1
    localSetHEAD(h,'row');    
    % time vector is stored as a column
    if ~isempty(h.IOData.SelectedRows)
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    end
else
    localSetHEAD(h,'column');    
    % time vector is stored as a row
    if ~isempty(h.IOData.SelectedColumns)
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end


function localChangeBlock(eventSrc, ~, h, token)
% callback for the editbox in the data panel
% 'token' parameter accepts 'FROM' and 'TO'

% get string from the FROM editbox
tmpStr=strtrim(get(h.Handles.EDTFROM,'String'));
% separate letters and number
[columnStr, rowStr]=strtok(tmpStr,'1234567890');
if isempty(columnStr) && isempty(rowStr)
    return
end
first_column=h.findcolumnnumber(columnStr);
first_row=str2double(rowStr);
if (isempty(first_column) || isnan(first_row)) && strcmp(token,'FROM')
    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
        set(eventSrc,'String','');
    else
        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
        localUpdateTableDisplay(h);
    end
    msgbox(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:UseStandardExcelCellFormat')),getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')));
    return
end
% get string from the TO editbox
tmpStr=strtrim(get(h.Handles.EDTTO,'String'));
% separate letters and number
[columnStr, rowStr]=strtok(tmpStr,'1234567890');
if isempty(columnStr) && isempty(rowStr)
    return
end
last_column=h.findcolumnnumber(columnStr);
last_row=str2double(rowStr);
if (isempty(last_column) || isnan(last_row)) && strcmp(token,'TO')
    if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
        set(eventSrc,'String','');
    else
        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
        localUpdateTableDisplay(h);
    end
    msgbox(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:UseStandardExcelCellFormat')),getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')));
    return
end
% get block size and check if it is a valid block    

% uitable is used
tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
if first_column>size(tmpSheet,2)
    first_column=size(tmpSheet,2);
end
if first_row>size(tmpSheet,1)
    first_row=size(tmpSheet,1);
end
set(h.Handles.EDTFROM,'String',[h.findcolumnletter(first_column) num2str(first_row)]);
if last_column>size(tmpSheet,2)
    last_column=size(tmpSheet,2);
end
if last_row>size(tmpSheet,1)
    last_row=size(tmpSheet,1);
end
set(h.Handles.EDTTO,'String',[h.findcolumnletter(last_column) num2str(last_row)]);
% deal with the first column/row for smart selection
selfirst_column=min(first_column,last_column);
sellast_column=max(first_column,last_column);
if get(h.Handles.COMBdataSample,'Value')==2
    % time vector is stored as a row
    if selfirst_column==1
        % first row is selected
        ignored=h.IgnoreFirstColumnRow;
        if ignored>0
            if sellast_column==selfirst_column
                if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                    set(eventSrc,'String','');
                else
                    if strcmp(token,'FROM')
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                    else
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                    end
                    localUpdateTableDisplay(h);
                end
                return
            else
                selfirst_column=ignored+1;
                sellast_column=max(sellast_column,selfirst_column);
            end
            if ignored==h.IOData.checkLimit
                msgbox(sprintf(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:FirsTimeValueInvalidAutoselection',...
                    h.IOData.checkLimit,h.IOData.checkLimit+1))),getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')));
            end
        end
    end
end
h.IOData.SelectedColumns=(selfirst_column:sellast_column)';
% deal with the first column/row for smart selection
selfirst_row=min(first_row,last_row);
sellast_row=max(first_row,last_row);
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    if selfirst_row==1
        % first row is selected
        ignored=h.IgnoreFirstColumnRow;
        if ignored>0
            if sellast_row==selfirst_row
                if isempty(h.IOData.SelectedColumns) || isempty(h.IOData.SelectedRows)
                    set(eventSrc,'String','');
                else
                    if strcmp(token,'FROM')
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(h.IOData.SelectedRows(1))]);
                    else
                        set(eventSrc,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(h.IOData.SelectedRows(end))]);
                    end
                    localUpdateTableDisplay(h);
                end
                return
            else
                selfirst_row=ignored+1;
                sellast_row=max(sellast_row,selfirst_row);
            end
            if ignored==h.IOData.checkLimit
                msgbox(sprintf(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:FirsTimeValueInvalidAutoselection',...
                    h.IOData.checkLimit,h.IOData.checkLimit+1))),getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')));
            end
        end
    end
end
h.IOData.SelectedRows=(selfirst_row:sellast_row)';
% refresh edit boxes
if strcmp(token,'FROM')
    set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selfirst_column) num2str(h.IOData.SelectedRows(1))]);
    set(h.Handles.EDTTO,'String',[h.findcolumnletter(sellast_column) num2str(h.IOData.SelectedRows(end))]);
else
    set(h.Handles.EDTFROM,'String',[h.findcolumnletter(h.IOData.SelectedColumns(1)) num2str(selfirst_row)]);
    set(h.Handles.EDTTO,'String',[h.findcolumnletter(h.IOData.SelectedColumns(end)) num2str(sellast_row)]);
end        
localUpdateTableDisplay(h);

if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    if ~isempty(h.IOData.SelectedRows)
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        set(h.Handles.EDTtimeSheetStart,'String','');
        set(h.Handles.EDTtimeSheetEnd,'String','');
    end
else
    % time vector is stored as a row
    if ~isempty(h.IOData.SelectedColumns)
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    else
        set(h.Handles.EDTtimeSheetStart,'String','');
        set(h.Handles.EDTtimeSheetEnd,'String','');
    end
end


function localUpdateTableDisplay(h) 

%%%% These statements are currently not migratable.
if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    rowSelection = double(h.Handles.tsTable.getTable.getSelectedRows);
    colSelection = double(h.Handles.tsTable.getTable.getSelectedColumns);
    % Change highlights avoiding creating a circular reference 
    if isempty(h.IOData.SelectedColumns) 
          awtinvoke(h.Handles.tsTable.getTable,'clearSelection()');  
    elseif isempty(colSelection) || ...
            (min(colSelection)~=h.IOData.SelectedColumns(1)-1) || ...
            (max(colSelection)~=h.IOData.SelectedColumns(end)-1)
              awtinvoke(h.Handles.tsTable.getTable,'addColumnSelectionInterval',...
                  h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
    end

    if isempty(h.IOData.SelectedRows)
        awtinvoke(h.Handles.tsTable.getTable,'clearSelection()'); 
    elseif isempty(rowSelection) || ...
        (min(rowSelection)~=(h.IOData.SelectedRows(1)-1)) || ...
        (max(rowSelection)~=(h.IOData.SelectedRows(end)-1))
          awtinvoke(h.Handles.tsTable.getTable,'addRowSelectionInterval',...
              h.IOData.SelectedRows(1)-1,h.IOData.SelectedRows(end)-1);
          if abs(max(rowSelection)-(h.IOData.SelectedRows(end)-1))>30
             awtinvoke(h.Handles.tsTable.getTable,'scrollRectToVisible',...
                h.Handles.tsTable.getTable.getCellRect(h.IOData.SelectedRows(end)-1,...
                h.IOData.SelectedColumns(end)-1,true));
          end
    end
    javaMethodEDT('repaint',h.Handles.tsTable.getTable);
end



function localSetHEAD(h,str) 
% change combobox contents in the tab panel
if strcmpi(str,'row')
    % a sample is a row
    huicTXTmultipleNEW = uicontextmenu('Parent',h.Figure);
    strSpecifyRow = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:SpecifyRow'));
    uimenu(huicTXTmultipleNEW,'Label',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:WhatsThisLabel')),'Callback','tsDispatchHelp(''its_wiz_name_ts_from_row'',''modal'')')
    set(h.Parent.Handles.TXTmultipleNEW,'String',sprintf('%s : ',strSpecifyRow),'UIContextMenu',huicTXTmultipleNEW);
    set(h.Parent.Handles.EDTmultipleNEW,'String','1');
    h.TimePanelUpdate('column');
else
    % a sample is a column
    huicTXTmultipleNEW = uicontextmenu('Parent',h.Figure);
    strSpecifyColumn = getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:SpecifyColumn'));
    uimenu(huicTXTmultipleNEW,'Label',getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:WhatsThisLabel')),'Callback','tsDispatchHelp(''its_wiz_name_ts_from_column_xls'',''modal'')')
    set(h.Parent.Handles.TXTmultipleNEW,'String',sprintf('%s : ',strSpecifyColumn),'UIContextMenu',huicTXTmultipleNEW);
    set(h.Parent.Handles.EDTmultipleNEW,'String','A');
    h.TimePanelUpdate('row');
end


% -------------------------------------------------------------------------
%% ActiveX callbacks
% -------------------------------------------------------------------------
% global functions

% -------------------------------------------------------------------------
%% uitable function and callbacks
% -------------------------------------------------------------------------
function localUITableSheetChanged(eventSrc, ~, h)
% reset table contents
%%%% NumRows and NumColumns are not available and are set by the size of
%%%% the data.  So these can probably be deleted if the data to be set is
%%%% the statement below.
set(h.Handles.tsTable,'NumRows',h.IOData.originalSheetSize(get(eventSrc,'Value'),1));
set(h.Handles.tsTable,'NumColumns',h.IOData.originalSheetSize(get(eventSrc,'Value'),2));

%%%% Java-like syntax is not available, use this instead:
%%%%   set(h.Handles.tsTable, 'Data', h.IOData.rawdata.(genvarname(h.IOData.DES{get(eventSrc,'Value')}));
h.Handles.tsTable.setData(h.IOData.rawdata.(genvarname(h.IOData.DES{get(eventSrc,'Value')})));

% clear selection
%%%% This is currently unavailable.
awtinvoke(h.Handles.tsTable.getTable,'clearSelection');

h.ClearEditBoxes;
% update time panel
% note: in this situation, no smart time vector detection for the first row
% or column.  the default time vector is along the first column
set(h.Handles.COMBdataSample,'Value',1);
h.TimePanelUpdate('column');
% use the active sheet name as the default time series object name
strCell=get(h.Handles.COMBdataSheet,'String');
set(h.Parent.Handles.EDTsingleNEW,'String',strCell{get(eventSrc,'Value')});


function localUITableDataChanged(eventSrc, ~, h)
% remember in Java, index starts from 0, instead of 1

% detect whether the selection is finished
if eventSrc.valueIsAdjusting
    return
end
% get starting row and column number
if ~ishandle(h.Handles.tsTable)
    return
end

%%%% This functionality is currently not migratable.
selcolumn=h.Handles.tsTable.getTable.getSelectedColumn+1;
selrow=h.Handles.tsTable.getTable.getSelectedRow+1;
if selcolumn==0 || selrow==0
    return
end

% get valid block size and treat single cell separately
%%%% This functionality is currently not migratable.
selsize(1)=length(h.Handles.tsTable.getTable.getSelectedRows);
selsize(2)=length(h.Handles.tsTable.getTable.getSelectedColumns);

% deal with the first column/row for smart selection
ignored=0;
if get(h.Handles.COMBdataSample,'Value')==1 
    % time vector is stored as a column 
    if selrow==1 
        % first row is selected 
        ignored=h.IgnoreFirstColumnRow; 
        if ignored>0 
            selrow=ignored+1; 
            selsize(1)=selsize(1)-ignored; 
        end 
    end 
    
   %%%% This functionality is currently not migratable.
    if selrow>h.Handles.tsTable.getTable.getRowCount 
        % starting row exceeds the used range, which means no time point 
        selrow=h.Handles.tsTable.getTable.getRowCount; 
        selsize(1)=1; 
    else 
        selsize(1)=min(selrow+selsize(1)-1,h.Handles.tsTable.getTable.getRowCount)-selrow+1; 
    end 
else 
    % time vector is stored as a row 
    if selcolumn==1 
        % first row is selected 
        ignored=h.IgnoreFirstColumnRow; 
        if ignored>0 
            selcolumn=ignored+1; 
            selsize(2)=selsize(2)-ignored; 
        end 
    end 
    if selcolumn>h.Handles.tsTable.getTable.getColumnCount 
        
        % starting column exceeds the used range, which means no time point 
        %%%% This functionality is currently not migratable.
        selcolumn=h.Handles.tsTable.getTable.getColumnCount; 
        selsize(2)=1; 
    else 
        selsize(2)=min(selcolumn+selsize(2)-1,h.Handles.tsTable.getTable.getColumnCount)-selcolumn+1; 
    end 
end 
% update selected block parameters
if isequal(h.IOData.SelectedColumns,selcolumn:selcolumn+selsize(2)-1) && ...
   isequal(h.IOData.SelectedRows,selrow:selrow+selsize(1)-1)      
    return
end
h.IOData.SelectedColumns=selcolumn:selcolumn+selsize(2)-1;
h.IOData.SelectedRows=selrow:selrow+selsize(1)-1;
% update displays in the editboxes
set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selcolumn) num2str(selrow)]);
set(h.Handles.EDTTO,'String',[h.findcolumnletter(selcolumn+selsize(2)-1) num2str(selrow+selsize(1)-1)]);
% check if a valid time vector exists (first and last elements)
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    h.updateStartEndTime(selrow,selrow+selsize(1)-1);
else
    % time vector is stored as a row
    h.updateStartEndTime(selcolumn,selcolumn+selsize(2)-1);
end
localUpdateTableDisplay(h)
if ignored==h.IOData.checkLimit
    msgbox(sprintf(getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:FirsTimeValueInvalid',...
        h.IOData.checkLimit))),getString(message('MATLAB:tsguis:excelImportdlg:initializeDataPanel:TimeSeriesTools')));
end
