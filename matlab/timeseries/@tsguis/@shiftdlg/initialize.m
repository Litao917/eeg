function initialize(h)

%   Copyright 2004-2012 The MathWorks, Inc.
%   % Revision % % Date %

import javax.swing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.mwswing.*;

%% Builds the Data Selection GUI

import javax.swing.*; 

%% Main figure
h.Figure = figure('Units','Characters','Position',[104 27.684 100 25],'Toolbar',...
    'None','Numbertitle','off','Menubar','None','Name', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:SynchronizeTimeSeries')),...
    'Visible','off','closeRequestFcn',{@localClose h},...
    'HandleVisibility','callback','IntegerHandle','off');

%% Top Time view selection panel
h.Handles.LBLselts = uicontrol('Style','Text','Parent',h.Figure,'Units','Characters',...
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:SelectTimePlot')),'HorizontalAlignment',...
    'Left');
set(h.Figure,'Color',get(h.Handles.LBLselts,'BackgroundColor'))
h.Handles.COMBOselectView = uicontrol('Style','Popupmenu','Parent', ...
    h.Figure,'Units','Characters',...
    'String',{''},'Callback',{@localSwitchView h});
if ~ismac
    set(h.Handles.COMBOselectView,'BackgroundColor',[1 1 1]);
end

%% Build time series table
h.Handles.tsTable = eventTable({});
drawnow % Be sure that table has finished populating
h.Handles.tsTable.getColumnModel.getColumn(0).setPreferredWidth(150);
h.Handles.tsTable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
thisScrollPane = MJScrollPane(h.Handles.tsTable); 
[~,h.Handles.tsTablePnl] = ...
    javacomponent(thisScrollPane,[0 0 1 1],h.Figure);
set(h.Handles.tsTablePnl,'Units','Pixels','Parent',h.Figure);

%% Time units label
h.Handles.LBLunits  = uicontrol('style','Text','Parent',h.Figure,'Units','Characters',...
    'String','','HorizontalAlignment',...
    'Left');

%% Dialog buttons
h.Handles.BTNok = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:OK')), ...
    'Callback',{@localOK h},'BusyAction','Cancel','Interruptible','off');
h.Handles.BTNapply = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:Apply')), ...
    'Callback',{@localEval h},'BusyAction','Cancel','Interruptible','off');
h.Handles.BTNcancel = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:Cancel')), ...
    'Callback',{@localClose h});
h.Handles.BTNhelp = uicontrol('style','Pushbutton','Parent',h.Figure,'Units','Characters',...
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:shiftdlg:Help')), ...
    'Callback',{@localDispatchhelp h});

%% Install viewnode and visibility listeners
h.generic_listeners

%% Layout
localFigResize(h.Figure,[],h);
set(h.Figure,'ResizeFcn',{@localFigResize h});

function localOK(~,~, h)

%% OK button callback

try % Prevent unexpected unexpected command line errors
    set(h.Figure,'Pointer','watch')
    status = h.eval;
    if status
       h.Visible = 'off';
    end
    set(h.Figure,'Pointer','arrow')
catch %#ok<CTCH>
    set(h.Figure,'Pointer','arrow')
end

function localSwitchView(eventSrc,~, h)

%% View combo callback which changes the viewNode
ind = get(eventSrc,'Value');
viewnames =  get(eventSrc,'String');
h.switchview(viewnames{ind});
    
function localFigResize(es,~,h)

pos = hgconvertunits(h.Figure,get(es,'Position'),get(es,'Units'),...
        'Characters',h.Figure);
if pos(3)<66 || pos(4)<14
    set(es,'Units','Characters','Position',[pos(1:2) 80 24]);
    centerfig(es);
    pos = get(es,'Position');
end

%% Reposition the buttons
set(h.Handles.BTNok,'Position',[pos(3)-65 1.3073  13.8 1.7687]);
set(h.Handles.BTNapply,'Position',[pos(3)-49.6 1.3073 13.8 1.7687]);
set(h.Handles.BTNcancel,'Position',[pos(3)-34.2 1.3073 13.8 1.7687]);
set(h.Handles.BTNhelp,'Position',[pos(3)-18.8 1.3073 13.8 1.7687]);

%% Reposition the units label
set(h.Handles.LBLunits,'Position',[2.6 4 68 1.7687]);


%% Reposition the table
pos1 = hgconvertunits(h.Figure,[2.6000  6.5341  pos(3)-6.2  pos(4)-11.08],'Characters',...
        'Pixels',h.Figure);
set(h.Handles.tsTablePnl,'Position',pos1);

%% Position the view selector
set(h.Handles.LBLselts,'Position',[2.8  pos(4)-2.9324 16.4 1.1535])
set(h.Handles.COMBOselectView,'Position',[21.4 pos(4)-3.47 pos(3)-27.9231 2.0763]);

function localClose(~,~,h)

set(h,'Visible','off')

function localEval(~,~,h)

eval(h)

function localDispatchhelp(~,~,h)

tsDispatchHelp('d_sync_ts','modal',h.Figure)