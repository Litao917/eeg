function dynamicPanel_Workspace(h)
% DYNAMICPANEL_WORKSPACE initializes dynamic panel

% Author: Rong Chen 
%  Copyright 1986-2012 The MathWorks, Inc.

h.Handles.PNLtimeWorkspace = uipanel('Parent',h.Handles.PNLtime,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'BorderType','none',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10 ...
                h.DefaultPos.TXTtimeSheetbottomoffset-h.DefaultPos.separation-5], ...
    'Visible','off' ...                
    );
% create sheet combobox controls whose values are based on the rawdata
h.Handles.BTNSelectVariableMat = uicontrol('Parent',h.Handles.PNLtimeWorkspace, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:MATFile')),...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset ...
                h.DefaultPos.TXTtimeIndexwidth/2-5 ...
                h.DefaultPos.heightbtn],...
    'Callback',{@localButtonMat h} ...
    );

huicBTNSelectVariableWorkspace = uicontextmenu('Parent',h.Figure);
h.Handles.BTNSelectVariableWorkspace = uicontrol('Parent',h.Handles.PNLtimeWorkspace, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Workspace')),...
    'UIContextMenu',huicBTNSelectVariableWorkspace,...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth/2+5 ...
                h.DefaultPos.TXTtimeIndexbottomoffset ...
                h.DefaultPos.TXTtimeIndexwidth/2-5 ...
                h.DefaultPos.heightbtn],...
    'Callback',{@localButtonWorkspace h} ...
    );
uimenu(huicBTNSelectVariableWorkspace,'Label',getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:WhatsThis')),'Callback','tsDispatchHelp(''its_wiz_select_variable_button'',''modal'')')

strUnits = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Units'));
h.Handles.TXTtimeWorkspaceFormat = uicontrol('Parent',h.Handles.PNLtimeWorkspace,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'HorizontalAlignment','Left', ...
    'String',sprintf('%s : ',strUnits), ...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset ...
                h.DefaultPos.TXTtimeIndexbottomoffset-32 ...
                40 ...
                h.DefaultPos.heighttxt] ...
    );
h.Handles.COMBtimeWorkspaceFormat = uicontrol('Parent',h.Handles.PNLtimeWorkspace,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',{getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Weeks')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Days')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Hours')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Minutes')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Seconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Milliseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Microseconds')), ...
        getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:Nanoseconds'))}, ...
    'Value',5, ...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset+50 ...
                h.DefaultPos.TXTtimeIndexbottomoffset-28 ...
                h.DefaultPos.TXTtimeIndexwidth-50 ...
                h.DefaultPos.heightcomb] ...
    );
if ~ismac
   set(h.Handles.COMBtimeWorkspaceFormat,'BackgroundColor',[1 1 1]);
end

    strSelectedTimeVector = getString(message('MATLAB:tsguis:matImportdlg:dynamicPanel_Workspace:SelectedTimeVector'));
    h.Handles.PNLDisplayWorkspaceInfo = uipanel('Parent',h.Handles.PNLtimeWorkspace,...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'Title',sprintf(' %s ',strSelectedTimeVector),...
    'Position',[h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation ...
                5 ...
                h.DefaultPos.widthpnl-10-h.DefaultPos.separation-(h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation) ...
                60] ...
    );
h.Handles.TXTDisplayWorkspaceInfo = uicontrol('Parent',h.Handles.PNLDisplayWorkspaceInfo,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',h.DefaultPos.TimePanelDefaultColor,...
    'String','',...
    'HorizontalAlignment','Left',...
    'Position',[5 ...
                5 ...
                h.DefaultPos.widthpnl-10-h.DefaultPos.separation-(h.DefaultPos.TXTtimeIndexleftoffset+h.DefaultPos.TXTtimeIndexwidth+h.DefaultPos.separation)-10 ...
                60-20] ...
    );


function localButtonMat(eventSrc, eventData, h)
%% Callback for the absolute/relative time format combo

tmp=tsguis.timeFromWorkspaceDlg(h.IOData.FileName);
tmp.Parent=h;
tmp.open;
h.IOData.timeFromWorkspace=tmp.OutputValue;
h.IOData.timeFormatFromWorkspace=tmp.OutputValueFormat;
if h.IOData.timeFormatFromWorkspace>=0
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','off');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','off');   
else
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','on');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','on');   
end
% display the selection
set(h.Handles.TXTDisplayWorkspaceInfo,'String',tmp.OutputString);


function localButtonWorkspace(eventSrc, eventData, h)
%% Callback for the absolute/relative time format combo

tmp=tsguis.timeFromWorkspaceDlg([]);
tmp.Parent=h;
tmp.open;
h.IOData.timeFromWorkspace=tmp.OutputValue;
h.IOData.timeFormatFromWorkspace=tmp.OutputValueFormat;
if h.IOData.timeFormatFromWorkspace>=0
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','off');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','off');   
else
    set(h.Handles.COMBtimeWorkspaceFormat,'Visible','on');    
    set(h.Handles.TXTtimeWorkspaceFormat,'Visible','on');   
end
% display the selection
set(h.Handles.TXTDisplayWorkspaceInfo,'String',tmp.OutputString);

