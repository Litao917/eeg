function TimePanelUpdate(h,option)
% TIMEPANELUPDATE updates the controls in time panel to the current display

% Author: Rong Chen 
%  Copyright 1986-2012 The MathWorks, Inc.

if strcmp(option,'column')
    % populate the index combo
    huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
     strTimeIsInColumn = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:TimeIsInColumn'));
     uimenu(huicTXTtimeIndex,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''its_wiz_time_column_mat'',''modal'')')
    set(h.Handles.TXTtimeIndex,'String',sprintf('%s : ',strTimeIsInColumn),'UIContextMenu',huicTXTtimeIndex);
    set(h.Handles.COMBtimeIndex,'String',h.GetColumn,'Value',1);
    % populate the unit/format combo
    if isfield(h.IOData.formatcell,'columnIsAbsTime') && h.IOData.formatcell.columnIsAbsTime>=0
        huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
        strFormat = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Format'));
        uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''time_display_format'',''modal'')')
        set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strFormat),'UIContextMenu',huicTXTtimeSheetFormat);
        set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
        set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.columnIsAbsTime));
    else
        huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
        strUnits = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Units'));
        uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''time_units_select'',''modal'')')
        set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strUnits),'UIContextMenu',huicTXTtimeSheetFormat);
        set(h.Handles.COMBtimeSheetFormat,'String',{getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Weeks')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Days')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Hours')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Minutes')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Seconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Milliseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Microseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Nanoseconds'))});    
        set(h.Handles.COMBtimeSheetFormat,'Value',5);
    end
else
    huicTXTtimeIndex = uicontextmenu('Parent',h.Figure);
    uimenu(huicTXTtimeIndex,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''its_wiz_time_row_mat'',''modal'')')
    strTimeIsInRow = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:TimeIsInRow'));
    set(h.Handles.TXTtimeIndex,'String',sprintf('%s : ',strTimeIsInRow),'UIContextMenu',huicTXTtimeIndex);
    set(h.Handles.COMBtimeIndex,'String',h.GetRow,'Value',1);
    % populate the unit/format combo
    if isfield(h.IOData.formatcell,'rowIsAbsTime') && h.IOData.formatcell.rowIsAbsTime>=0
        huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''time_display_format'',''modal'')')
        strFormat = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Format'));
        set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strFormat),'UIContextMenu',huicTXTtimeSheetFormat);
        set(h.Handles.COMBtimeSheetFormat,'String',h.IOData.formatcell.matlabFormatString);    
        set(h.Handles.COMBtimeSheetFormat,'Value',find(h.IOData.formatcell.matlabFormatIndex == h.IOData.formatcell.rowIsAbsTime));
    else
        % populate the unit/format combo
        huicTXTtimeSheetFormat = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTtimeSheetFormat,'Label',getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:WhatsThis')),'Callback','tsDispatchHelp(''time_units_select'',''modal'')')
        strUnits = getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Units'));
        set(h.Handles.TXTtimeSheetFormat,'String',sprintf('%s : ',strUnits),'UIContextMenu',huicTXTtimeSheetFormat);
        set(h.Handles.COMBtimeSheetFormat,'String',{getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Weeks')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Days')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Hours')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Minutes')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Seconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Milliseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Microseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:TimePanelUpdate:Nanoseconds'))});    
        set(h.Handles.COMBtimeSheetFormat,'Value',5);
    end
end