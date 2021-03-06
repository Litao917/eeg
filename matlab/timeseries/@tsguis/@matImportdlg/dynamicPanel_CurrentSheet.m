function dynamicPanel_CurrentSheet(h)
% DYNAMICPANEL_CURRENTSHEET initializes dynamic panel

% Author: Rong Chen 
%  Copyright 1986-2012 The MathWorks, Inc.

% create first dynamic panel for 'current sheet' selection

h.Handles.PNLtimeCurrentSheet = uipanel('Parent',h.Handles.PNLtime,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'BorderType','none',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10 ...
                h.DefaultPos.TXTtimeSheetbottomoffset-h.DefaultPos.separation-5], ...
    'Visible','on' ...                                
    );

% sheet combobox controls whose values are based on the rawdata
% huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeIndex = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset ...
                h.DefaultPos.TXTtimeIndexwidth ...
                h.DefaultPos.heighttxt] ...
    );
% 'UIContextMenu',huicTXTtimeIndex,...
% uimenu(huicTXTtimeIndex,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''its_wiz_time_column_row_mat'',''modal'')')

h.Handles.COMBtimeIndex = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',' ',...
    'TooltipString',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:SelectRowColumnTimeVector')),...
    'Position',[h.DefaultPos.COMBtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset+4 ...
                h.DefaultPos.COMBtimeIndexwidth ...
                h.DefaultPos.heightcomb], ...
    'Callback',{@localSwitchIndex h}, ...
    'Tag', 'COMBtimeIndex');

if ~ismac
   set(h.Handles.COMBtimeIndex,'BackgroundColor',[1 1 1]);
end

% huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeSheetFormat = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'HorizontalAlignment','Left', ...
    'Position',[h.DefaultPos.TXTtimeSheetFormatleftoffset ...
                h.DefaultPos.TXTtimeSheetFormatbottomoffset ...
                h.DefaultPos.TXTtimeSheetFormatwidth ...
                h.DefaultPos.heighttxt] ...
    );
% 'UIContextMenu',huicTXTtimeSheetFormat,...
% uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_units_format_select'',''modal'')')

h.Handles.COMBtimeSheetFormat = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',' ',...
    'TooltipString',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:SelectProperTimeDateFormat')),...
    'Position',[h.DefaultPos.COMBtimeSheetFormatleftoffset ...
                h.DefaultPos.TXTtimeSheetFormatbottomoffset+4 ...
                h.DefaultPos.COMBtimeSheetFormatwidth ...
                h.DefaultPos.heightcomb], ...
    'Tag', 'COMBtimeSheetFormat');

if ~ismac
   set(h.Handles.COMBtimeSheetFormat,'BackgroundColor',[1 1 1]);
end

% start, end
huicTXTtimeSheetStart = uicontextmenu('Parent',h.Figure);
strTime = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Time'));
strFirstValue = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:FirstValue'));
h.Handles.TXTtimeSheetStart = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String',sprintf('%s :   %s ',strTime,strFirstValue),...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTtimeSheetStart,...
    'Position',[h.DefaultPos.TXTtimeSheetStartleftoffset ...
                h.DefaultPos.TXTtimeSheetStartbottomoffset ...
                h.DefaultPos.TXTtimeSheetStartwidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTtimeSheetStart,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_first'',''modal'')')

h.Handles.EDTtimeSheetStart = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','edit', ...
    'Units','Pixels',...
    'BackgroundColor',[1 1 1],...
    'String',' ',...
    'TooltipString',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:PutInStartingPointOfTimeRange')),...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtimeSheetStartleftoffset ...
                h.DefaultPos.TXTtimeSheetStartbottomoffset+2 ...
                h.DefaultPos.EDTtimeSheetStartwidth ...
                h.DefaultPos.heightedt], ...
    'Callback',{@localChangeTime h}, ...  
    'Tag', 'EDTtimeSheetStart');

strLastValue = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:LastValue'));
huicTXTtimeSheetEnd = uicontextmenu('Parent',h.Figure);
h.Handles.TXTtimeSheetEnd = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String',sprintf('%s ',strLastValue),...
    'HorizontalAlignment','Left', ...
    'UIContextMenu',huicTXTtimeSheetEnd,...
    'Position',[h.DefaultPos.TXTtimeSheetEndleftoffset ...
                h.DefaultPos.TXTtimeSheetEndbottomoffset ...
                h.DefaultPos.TXTtimeSheetEndwidth ...
                h.DefaultPos.heighttxt] ...
    );
uimenu(huicTXTtimeSheetEnd,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_last'',''modal'')')

h.Handles.EDTtimeSheetEnd = uicontrol('Parent',h.Handles.PNLtimeCurrentSheet,...
    'style','edit', ...
    'Units','Pixels',...
    'BackgroundColor',[1 1 1],...
    'String',' ',...
    'TooltipString',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:PutInEndingPointOfTimeRange')),...
    'HorizontalAlignment','Left',...
    'Position',[h.DefaultPos.EDTtimeSheetEndleftoffset ...
                h.DefaultPos.TXTtimeSheetEndbottomoffset+2 ...
                h.DefaultPos.EDTtimeSheetEndwidth ...
                h.DefaultPos.heightedt], ...
    'Callback',{@localChangeTime h}, ...
    'Tag', 'EDTtimeSheetEnd');

% -------------------------------------------------------------------------
%% current sheet dynamic panel callbacks
% -------------------------------------------------------------------------
function localChangeTime(eventSrc, eventData, h)
% callback of edit boxes

% get first row
first=strtrim(get(h.Handles.EDTtimeSheetStart,'String'));
% get last row
last=strtrim(get(h.Handles.EDTtimeSheetEnd,'String'));
% get time range
if ~isempty(first) && ~isempty(last)
    [timeindex,timeValue]=h.getTimeVectorRange(first,last);
else
    return
end
if isempty(timeindex)
    % due to the drawnow issue in the errordlg function, we have to set
    % the callback functions of the two editboxes to [] first and then
    % set them back to normal status after the errordlg is called 
    set(h.Handles.EDTtimeSheetStart,'Callback',[]);
    set(h.Handles.EDTtimeSheetEnd,'Callback',[]);
    % if previous valid selection exists, restore it
    if get(h.Handles.COMBdataSample,'Value')==1
        if ~isempty(h.IOData.SelectedRows)
            updateStartEndTime(h,h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    else
        if ~isempty(h.IOData.SelectedColumns)
            updateStartEndTime(h,h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
        else
            set(h.Handles.EDTtimeSheetStart,'String','');
            set(h.Handles.EDTtimeSheetEnd,'String','');
        end
    end
    errordlg(getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:InvalidTimeRange')),getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:TimeSeriesTools')),'modal');
    % 
    set(h.Handles.EDTtimeSheetStart,'Callback',{@localChangeTime h});
    set(h.Handles.EDTtimeSheetEnd,'Callback',{@localChangeTime h});
else
    if get(h.Handles.COMBdataSample,'Value')==1
        h.IOData.SelectedRows=(timeindex(1):timeindex(end))';
    else
        h.IOData.SelectedColumns=(timeindex(1):timeindex(end))';
    end
    % update displays in the editboxes
    set(h.Handles.EDTFROM,'String',[num2str(h.IOData.SelectedRows(1)) ':' num2str(h.IOData.SelectedRows(end))]);
    set(h.Handles.EDTTO,'String',[num2str(h.IOData.SelectedColumns(1)) ':' num2str(h.IOData.SelectedColumns(end))]);
end


function localSwitchIndex(eventSrc, eventData, h)
if get(h.Handles.COMBdataSample,'Value')==1
    % a sample is a row (time vector is a column)
    localSwitchColumn(h);
else
    % a sample is a column (time vector is a row)
    localSwitchRow(h);
end


function localSwitchColumn(h)
% callback for the column combobox in the time panel
% check if a valid time vector exists
columnLength=h.IOData.SelectedVariableInfo.objsize(2);
if get(h.Handles.COMBtimeIndex,'Value')==h.IOData.checkLimitColumn+1
    % if user selects the 'More ...' option, generate a modal window to
    % let user put in column letter
    numlines=1;
    strEnterColumnIndexTimeVector = [getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:EnterColumnIndexTimeVector')) '         '];
    answer=inputdlg(strEnterColumnIndexTimeVector,getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:TimeSeriesTools')),numlines);
    if isempty(answer)
        % user select 'cancel', jump back to first
        set(h.Handles.COMBtimeIndex,'Value',1);
    else
        % check if it a valid column name
        columnIndex=str2double(cell2mat(answer));
        if isempty(columnIndex) || columnIndex>columnLength || columnIndex<1
            % wrong name or column name is invalid
            set(h.Handles.COMBtimeIndex,'Value',1);
        else
            strCell=get(h.Handles.COMBtimeIndex,'String');
            findindex=strfind(strCell,cell2mat(answer));
            if sum(cell2mat(findindex))>0
                % already exist in the combo
                set(h.Handles.COMBtimeIndex,'Value',find(not(cellfun('isempty',findindex))));
            else
                % new selection
                % insert the column name into the combobox
                strCell=[strCell(1:h.IOData.checkLimitColumn);answer;strCell(h.IOData.checkLimitColumn+1)];
                set(h.Handles.COMBtimeIndex,'String',strCell);
                % make it current selection
                set(h.Handles.COMBtimeIndex,'Value',h.IOData.checkLimitColumn+1);
                % change the checklimit
                h.IOData.checkLimitColumn=h.IOData.checkLimitColumn+1;
            end
        end
    end
end
% display
if isfield(h.IOData.formatcell,'columnIsAbsTime') && h.IOData.formatcell.columnIsAbsTime>=0
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    strFormat = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Format'));
    uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_display_format'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strFormat),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
    set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.columnIsAbsTime));
else
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    strUnits = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Units'));
    uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_units_select'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strUnits),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',{getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Weeks')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Days')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Hours')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Minutes')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Seconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Milliseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Microseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Nanoseconds'))});    
    set(h.Handles.COMBtimeSheetFormat,'Value',5);
end
if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        % time vector is stored as a row
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end



function localSwitchRow(h)
% callback for the row combobox in the time panel
rowLength=h.IOData.SelectedVariableInfo.objsize(1);
if get(h.Handles.COMBtimeIndex,'Value')==h.IOData.checkLimitRow+1
    % if user selects the 'More ...' option, generate a modal window to
    % let user put in row index
    numlines=1;
    strEnterRowIndexTimeVector = [getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:EnterRowIndexTimeVector')) '        '];
    answer=inputdlg(strEnterRowIndexTimeVector,getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:TimeSeriesTools')),numlines);
    if isempty(answer)
        % user select 'cancel', jump back to first
        set(h.Handles.COMBtimeIndex,'Value',1);
    else
        % check if it a valid row index
        rowIndex=str2double(cell2mat(answer));
        if isempty(rowIndex) || rowIndex>rowLength || rowIndex<1
            % wrong index or index is invalid
            set(h.Handles.COMBtimeIndex,'Value',1);
        else
            strCell=get(h.Handles.COMBtimeIndex,'String');
            findindex=strfind(strCell,cell2mat(answer));
            if sum(cell2mat(findindex))>0
                % already exist in the combo
                set(h.Handles.COMBtimeIndex,'Value',find(not(cellfun('isempty',findindex))));
            else
                % new selection
                % insert the row index into the combobox
                strCell=[strCell(1:h.IOData.checkLimitRow);answer;strCell(h.IOData.checkLimitRow+1)];
                set(h.Handles.COMBtimeIndex,'String',strCell);
                % make it current selection
                set(h.Handles.COMBtimeIndex,'Value',h.IOData.checkLimitRow+1);
                % change the checklimit
                h.IOData.checkLimitRow=h.IOData.checkLimitRow+1;
            end
        end
    end
end
% display
if isfield(h.IOData.formatcell,'rowIsAbsTime') && h.IOData.formatcell.rowIsAbsTime>=0
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    strFormat = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Format'));
    uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_display_format'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strFormat),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
    set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.rowIsAbsTime));
else
    % populate the unit/format combo
    huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
    strUnits = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Units'));
    uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:WhatsThis')),'Callback','tsDispatchHelp(''time_units_select'',''modal'')')
    set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strUnits),'UIContextMenu',huicTXTtimeSheetFormat);
    set(h.Handles.COMBtimeSheetFormat,'String',{getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Weeks')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Days')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Hours')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Minutes')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Seconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Milliseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Microseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_CurrentSheet:Nanoseconds'))});    
    set(h.Handles.COMBtimeSheetFormat,'Value',5);
end
if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        h.updateStartEndTime(h.IOData.SelectedRows(1),h.IOData.SelectedRows(end));
    else
        % time vector is stored as a row
        h.updateStartEndTime(h.IOData.SelectedColumns(1),h.IOData.SelectedColumns(end));
    end
end

