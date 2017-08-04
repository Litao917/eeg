function initialize(h,manager)

%   Copyright 2004-2012 The MathWorks, Inc.
%   % Revision % % Date %
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

%% Builds the Descriptive Stats dialog

% % % % %% Main figure
h.Figure = figure('Units','Characters','Position',[103 31 77.2 30.6],'Toolbar',...
    'None','Numbertitle','off','Menubar','None','Name', ...
    getString(message('MATLAB:timeseries:tsguis:statsdlg:DescriptiveStatistics')),...
    'Visible','off','closeRequestFcn',{@localClose h},...
    'HandleVisibility','callback','IntegerHandle','off','Resize','off', 'Tag', 'DescriptiveStats');
centerfig(h.Figure);

% Labels
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[2.8 27.61 17.8 1.154],'String', ...
    getString(message('MATLAB:timeseries:tsguis:statsdlg:SelectTimeSeries')),...
    'HorizontalAlignment','Left');
uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'Position',[2.8 14.154 55.2 1.154],'String',...
    getString(message('MATLAB:timeseries:tsguis:statsdlg:DescriptiveStatisticsSummary')),...
    'HorizontalAlignment','Left');

%% Build time series table
h.Handles.tsTableModel = tsMatlabCallbackTableModel(cell(0,3),...
             {getString(message('MATLAB:timeseries:tsguis:statsdlg:TimeSeries')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:Path')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:NumberOfColumns'))},...
             [],[]);
h.Handles.tsTableModel.setEditable(false);
drawnow
h.Handles.tsTable = MJTable(h.Handles.tsTableModel);
h.Handles.tsTable.setName('statsdlg:tstable');
h.Handles.tsTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
h.Handles.tsTable.getColumnModel.getColumn(1).setPreferredWidth(150);
h.Handles.tsTable.getColumnModel.getColumn(2).setPreferredWidth(150);
h.Handles.tsTable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
h.Handles.tsTable.setCellSelectionEnabled(false);
h.Handles.tsTable.setRowSelectionAllowed(true);
sPanel = MJScrollPane(h.Handles.tsTable);
[~, tsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
set(tsTablePanel,'Parent',h.Figure,'Units','Characters','Position',...
    [4 18 69.4 8.385])

%% 1st column is HTML
h.SrcNode.setHTMTableColumn(h.Handles.tsTable);

%% List selection listener must update time series table changed status
listSelectionListener = ...
    handle(h.Handles.tsTable.getSelectionModel,'callbackproperties');
listSelectionListener.ValueChangedCallback = {@localTsSelection h};

%% Stats table
h.Handles.statsTableModel = tsMatlabCallbackTableModel(cell(0,6),...
             {getString(message('MATLAB:timeseries:tsguis:statsdlg:ColumnNumber')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:Mean')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:Median')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:STD')), ...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:Min')),...
             getString(message('MATLAB:timeseries:tsguis:statsdlg:Max'))},...
             [],[]);
h.Handles.statsTableModel.setEditable(false);
drawnow
h.Handles.statsTable = javaObjectEDT('com.mathworks.mwswing.MJTable',...
    h.Handles.statsTableModel);
h.Handles.statsTable.setName('statsdlg:statstable');
javaMethod('setAutoResizeMode',h.Handles.statsTable,...
    JTable.AUTO_RESIZE_ALL_COLUMNS);
sPanel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',...
    h.Handles.statsTable);
[~, statsTablePanel] = javacomponent(sPanel,[0 0 1 1],h.Figure);
set(statsTablePanel,'Parent',h.Figure,'Units','Characters','Position',...
    [4 5 69.4 8.385])

% Dialog buttons
BTNcancel = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[59.8-15 0.769 13.8 1.769],'String', ...
    getString(message('MATLAB:timeseries:tsguis:statsdlg:Close')),'Callback', ...
    {@localClose h}, 'Tag', 'BTNClose');
uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'Position',[59.8 0.769 13.8 1.769],'String', ...
    getString(message('MATLAB:timeseries:tsguis:statsdlg:Help')),'Callback', ...
    'tsDispatchHelp(''d_descriptive_statistics'',''modal'')');
set(h.Figure,'Color',get(BTNcancel,'BackgroundColor'));

% Install general listeners
h.generic_listeners
manager.Listeners.addListeners(handle.listener(manager,manager.findprop('Visible'),...
    'PropertyPostSet',{@localHide h manager}));

function localTsSelection(~,eventData,h)

% Callback for row selection in time series table
selectedRow = eventData.getSource.getMaxSelectionIndex+1;
if selectedRow>0
    tableData = cell(h.Handles.tsTable.getModel.getData);
    tspath = tableData{selectedRow,2};
    h.Timeseries = h.Srcnode.search(tspath).Timeseries;
    h.updatestats
end

h.tslisteners = handle.listener(h.Timeseries,'datachange', ...
    {@localUpdateStats h}); 

function localHide(~,~,h,manager)

% Listener to tree manager hide will hide the stats dlg
if strcmp(manager.Visible,'off')
    set(h,'Visible','off')
end

function localClose(~,~,h)

set(h,'Visible','off')

function localUpdateStats(~,~,h)

updatestats(h);
