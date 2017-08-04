function Panel = getDialogSchema(this,manager)

%  Copyright 2004-2011 The MathWorks, Inc.


import javax.swing.*;

%% Create the node panel and components
% note: '.12g' is used as the sprintf format to display values in the
% 'redefine uniform time vector' panel.
Panel = localBuildPanel(manager.Figure,this,manager);

%% Add a listener to node renaming
Lrename = handle.listener(this.getRoot,'tsstructurechange',{@localTsNameChange this});
Lrename.CallbackTarget = this.up;
this.addListeners(Lrename);

%% Listener to show the current time vector 
L = handle.listener(this.Timeseries,'DataChange',{@localUpdateTimeStr this});
this.addListeners(L);

%% Listener to destroy new time vector dialog
L = handle.listener(this,'ObjectParentChanged',@(es,ed) delete(get(this,'TimeResetPanel')));
this.addListeners(L);

set(this.Handles.PNLdata,'Visible','on')
% Remove the call to figure, so that hitting apply on the @arithdlg does
% not cause that dialog to lose focus
% if strcmp(manager.Visible,'on')
%     figure(double(manager.Figure))
% end

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
f = uipanel('Parent',thisfig,'Units','Characters','Visible','off');

%% Data split pane
editPanelStr = getString(message('MATLAB:timeseries:tsguis:tsnode:EditDataFor',h.Timeseries.Name));
h.Handles.PNLdata = uipanel('Parent',f,'Units','Characters','Title',editPanelStr,...
    'ResizeFcn',{@localDataResize h},'Visible','off');

%% Top tsdata panel
h.Handles.PNLtstable = uipanel('Parent',h.Handles.PNLdata,'Units','Characters',...
    'BorderType','None');

h.Handles.CHKevents = uicontrol('Style','checkbox','Parent',h.Handles.PNLtstable, ...
    'Units','Characters','String',getString(message('MATLAB:timeseries:tsguis:tsnode:ShowEventTable')),...
    'Value',false,'Callback',{@localShowEventTable h});
BTNattributes = uicontrol('Style', 'pushbutton','Parent',h.Handles.PNLtstable, ...
    'Units','Characters','String',getString(message('MATLAB:timeseries:tsguis:tsnode:Attributes')),'Callback',...
    @(es,ed) tsguis.attributesdlg(h,'open'),'Tag','BTNattributes');
h.Handles.BTNaddrow = uicontrol('Style','pushbutton','Parent',h.Handles.PNLtstable, ...
    'Units','Characters','String',...
    getString(message('MATLAB:timeseries:tsguis:tsnode:AddRow')),'Callback',@(es,ed) addrow(get(h,'Tstable')),'Tag','BTNaddrow');
h.Handles.BTNdelrow = uicontrol('Style','pushbutton','Parent',h.Handles.PNLtstable, ...
    'Units','Characters','Interruptible','off',...
    'String',getString(message('MATLAB:timeseries:tsguis:tsnode:DeleteRows')),'Callback',{@localDelrow,h},'Tag','BTNdelrow');

%% Events panel
h.Handles.PNLevents = uipanel('Parent',h.Handles.PNLdata,'Units','Characters',...
    'BorderType','None');
if ~isempty(h.Timeseries.Events)
    set(h.Handles.CHKevents,'Value',true);
    h.eventpnl(h.Handles.PNLevents);
else
    h.Handles.PNLeventTable = [];
end

%% Build the tstableadaptor 
h.Tstable = tsdata.tstableadaptor;
h.Tstable.timeseries = h.Timeseries;
h.Tstable.build;
PNLtable = h.Tstable.addtopanel(h.Handles.PNLtstable);

%% Time vector panel
h.Handles.LBLCurrentTimeVec = uicontrol('Style','Text','Parent',h.Handles.PNLdata, ...
    'Units','Characters','String','','Position',[2.5 0.5 60 1.5],'HorizontalAlignment',...
    'Left');
localUpdateTimeStr([],[],h);
h.Handles.BTNNewTimeVec = uicontrol('Style','PushButton','Parent',h.Handles.PNLdata, ...
    'Units','Characters','String',getString(message('MATLAB:timeseries:tsguis:tsnode:UniformTimeVector')),...
    'Callback', {@localShowTimeReset h},'Tag','BTNNewTimeVec');

%% Size table
tablePos =  hgconvertunits(ancestor(PNLtable,'figure'),...
             [5.4 5.6137 117.6 31.1445],...
            'Characters','Pixels',get(PNLtable,'Parent'));
set(PNLtable,'Parent',h.Handles.PNLtstable,'Position',tablePos)
set(h.Handles.PNLtstable, 'resizeFcn', ...
    {@localTablePnlResize BTNattributes h.Handles.BTNaddrow ...
    h.Handles.BTNdelrow h.Handles.CHKevents PNLtable});


%% View panel
h.NewPlotPanel = tsguis.newplotpanel;
h.NewPlotPanel.initialize(f,manager,h);
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLdata   ...
     h.NewPlotPanel.Panel});

%--------------------------------------------------------------------------
function localFigResize(es,ed,PNLdata,BTNGRPdisp)

%% Resize callback for tsnode panel
 
%% No-op if the panel is invisible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));

set(BTNGRPdisp,'Position',[1.8 1.2304 max(1,mainpnlpos(3)-4.8) 6]);

%% Set the table panel size to take up remaining space
set(PNLdata,'Position',[1.8 7.8 max(1,mainpnlpos(3)-4.8) max(1,mainpnlpos(4)-8.5)]);

%--------------------------------------------------------------------------
% function localSetVisible(es,ed,h,CHKevents,PNLevents)
% 
% children = h.find('-depth',inf,'-isa','hgjavacomponent');
% for k=1:length(children)
%     % Do not turn the events panel visible if the events check box is off
%     if children(k)~=PNLevents || get(CHKevents,'Value')>0.5  || ...
%             (get(CHKevents,'Value')<0.5 && strcmp(get(h,'Visible'),'off'))
%         set(children(k),'Visible',get(h,'Visible'));
%     end        
% end
 

%--------------------------------------------------------------------------
function localTsNameChange(~,eventData,tsnode)

% Response to tsnode name-change event

%% Rename only
if ~strcmp(eventData.Action,'rename') || ...
        eventData.Node~=tsnode
    return
end

% Update parent panel
if ~isempty(eventData.Node.up.getParentNode)
    eventData.Node.up.updatePanel('child_rename');
end

% Update tsnode group box label
editPanelStr = getString(message('MATLAB:timeseries:tsguis:tsnode:EditDataFor',eventData.Node.Timeseries.Name));
set(eventData.Node.Handles.PNLdata,'Title',editPanelStr);


%--------------------------------------------------------------------------
function localTablePnlResize(eventSrc,~, BTNattributes, ...
    BTNaddrow,BTNdelrow,CHKevents,PNLtable)

%% Table panel resize function keeps the buttons on the bottom right hand
%% corner - the table takes up the remaining space
pos = get(eventSrc, 'Position');
set(BTNattributes,'Position',[max(1,pos(3)-47) 1 15 1.4611]);
set(BTNaddrow,'Position',[max(1,pos(3)-31) 1 14 1.46 ]);
set(BTNdelrow,'Position',[max(1,pos(3)-16) 1 15 1.46 ]);
set(CHKevents,'Position',[1 1 28 1.46 ]);
tablePos =  hgconvertunits(ancestor(PNLtable,'figure'),...
             [1 3.46 max(1,pos(3)-2) max(1,pos(4)-3.46-1)],...
            'Characters','Pixels',get(PNLtable,'Parent'));
set(PNLtable,'Position',tablePos);


%--------------------------------------------------------------------------
function localDataResize(es,~,h)

%% Data panel resize fcn
pos = get(es,'Position');

if get(h.Handles.CHKevents,'Value')>0.5
    set(h.Handles.PNLtstable,'Position',[1 2+pos(4)*.4 max(1,pos(3)-2) max(1,pos(4)*.6-3)]);
    set(h.Handles.PNLevents,'Position',[1 4.5 max(1,pos(3)-2) pos(4)*.4-2]); 
else
    set(h.Handles.PNLtstable,'Position',[1 2.5 max(1,pos(3)-2) max(1,pos(4)-4)]);
end
set(h.Handles.BTNNewTimeVec,'Position',[max(1,pos(3)-31) .8 29 1.5]);

%--------------------------------------------------------------------------
function localShowEventTable(~,~,h)

%% Events checkbox callback which shown the event pane

%% If necessary build event panel
if isempty(h.Handles.PNLeventTable)
    h.eventpnl(h.Handles.PNLevents);
end

%% Toggle event panel visibility
if get(h.Handles.CHKevents,'Value')
    set(h.Handles.PNLevents,'Visible','on');
    %set(h.Handles.PNLeventTable,'Visible','on');
else
    set(h.Handles.PNLevents,'Visible','off');
    %set(h.Handles.PNLeventTable,'Visible','off');
end
localDataResize(h.Handles.PNLdata,[],h);


%--------------------------------------------------------------------------
function localDelrow(~,~,h)

if isa(h.up,'tsguis.tscollectionNode')
    iscoll = true;
else
    iscoll = false;
end

hT = get(h,'Tstable');
selrow = hT.Table.getSelectedRows;

if ~isempty(selrow)
    % If this is not child of tscollection instantiate a transaction for 
    % row-deletion action, otherwise let the @tsCollectionNode
    % utMaybeRefreshChildrenData do this
    if ~iscoll
        recorder = tsguis.recorder;
        T = tsguis.transaction;
        T.ObjectsCell = [T.ObjectsCell, {h.Timeseries}];
    end
    
    % Delete the row
    delrow(hT)

    if ~iscoll && strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:tsnode:DeleteRowsFromTimeseries',genvarname(h.Timeseries.Name)))]);
        T.addbuffer(sprintf('%s = delsample(%s, ''index'',[%s]);',...
            genvarname(h.Timeseries.Name), genvarname(h.Timeseries.Name),...
            num2str(selrow(:)'+1)),h.Timeseries);
    end

    % Commit and store the transaction
    if ~iscoll
        T.commit;
        recorder.pushundo(T);
    end
end

function localUpdateTimeStr(~,~,h)

if ~isempty(h.up) && ishandle(h.up)
    set(h.Handles.LBLCurrentTimeVec,'String',...
        h.Timeseries.TimeInfo.getTimeStr);
end

function localShowTimeReset(~,~,h)

import com.mathworks.toolbox.timeseries.*;

tsguis.tsUniformTimeDlg(h,'open')


