function Panel = getDialogSchema(this, manager)
%create the panel for tscollection object node

%   Author(s): Rajiv Singh
%   Copyright 2005-2012 The MathWorks, Inc.

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Install listeners which update the tscollection table
this.addListeners([...
    handle.listener(this,'ObjectChildAdded',{@localChildAdded this}); ...
    handle.listener(this,'ObjectChildRemoved',{@localRemoveTsNode this}); ...
    handle.listener(this,'ObjectParentChanged',{@localDelete this})]);

Lrename = handle.listener(this, this.findprop('Label'),'PropertyPostSet',...
    {@localTsCollNameChange});
Lrename.CallbackTarget = this;
this.addListeners(Lrename);

%% Show the panel
figure(double(manager.Figure));

%--------------------------------------------------------------------------
function Panel = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
import javax.swing.*;

%% Build tscollection panel
h.Handles.PNLTsOuter = uipanel('Parent',thisfig,'Units','Characters','Visible','off');
Panel = h.Handles.PNLTsOuter;
localConfigureMembersPanel(h);
localConfigureTimeInfoPanel(h);
localConfigurePlotPanel(h,manager);   

set(h.Handles.PNLTsOuter,'resizefcn',{@localPanelResize,h});
localPanelResize(h.Handles.PNLTsOuter,[],h);

%--------------------------------------------------
function localConfigureMembersPanel(h)

% Configure the contents of the "Manage Collection Members" panel

h.Handles.pnlMembers = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:ManageCollectionMembers')),'tag','tsmembers','vis','on');

%% Add table
h.tscollectionMembersTable;

%% Add delete/add/extract push buttons
h.Handles.importBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'String',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Add')),'pos',[1 1 1 1]/10,'tag','importBtn',...
    'Callback',{@localimportTsCallback h});

%% Add remove button
h.Handles.removeBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'String',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Remove')),...
    'pos',[1 1 1 1]/10,'tag','removeBtn','Callback',{@localremoveTsCallback h});

%% Add extract timeseries button
h.Handles.extractBtn = uicontrol('parent',h.Handles.pnlMembers,'style','pushbutton','units','Characters',...
    'string',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Extract')),'pos',[1 1 1 1]/10,'tag','extractBtn','Callback',{@localExtractTs h});

%% Resize function
set(h.Handles.pnlMembers,'resizefcn',{@localMembersResize h});

%--------------------------------------------------------------------------
function localConfigureTimeInfoPanel(h)
% Configure the contents of the "Edit Time Vector" panel
import javax.swing.*;

h.Handles.pnlTimeInfo = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:EditTimeVector')),'tag','timepanel_left');

%% Add time vector table
h.Handles.timeTable = tsdata.tscolltableadaptor;
h.Handles.timeTable.Timeseries = h.Tscollection;
h.Handles.timeTable.build;
h.Handles.PNLtimeTable = h.Handles.timeTable.addtopanel(h.Handles.pnlTimeInfo);
awtinvoke(h.Handles.timeTable.Table,'setAutoResizeMode(I)',JTable.AUTO_RESIZE_ALL_COLUMNS);

%% Size time table
set(h.Handles.PNLtimeTable,'Units','Characters',...
    'Parent',h.Handles.pnlTimeInfo);

%% Add current timeinfo text to the edit time panel
h.tscollectionCurrentTimeDisplay;
set(h.Handles.currentTimeInfo,'parent',h.Handles.pnlTimeInfo,'vis','on');

%% Add Delete Sample button
h.Handles.deleteBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Delete')),'tag','TimeRemoveBtn',...
    'callback',{@localDeleteTimeSamples,h});

%% Add new time vector button
h.Handles.newTimeBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:UniformTimeVector')),'Callback',{@localShowTimeReset h},'Tag','newTimeBtn');

%% Add "Insert time sample" button
h.Handles.addBtn = uicontrol('parent',h.Handles.pnlTimeInfo,'style','pushbutton','units','Characters',...
    'string',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Insert')),'tag','TimeInsertBtn',...
    'callback',{@localInsertTimeSample,h});

%% Resize function
set(h.Handles.pnlTimeInfo,'resizefcn',{@localEditTimeResize h});
localEditTimeResize(h.Handles.pnlTimeInfo,[],h);

%--------------------------------------------------------------------------
function localConfigurePlotPanel(h,manager)

% Configure the contents of the plot panel
h.Handles.pnlPlot = uipanel('Parent',h.Handles.PNLTsOuter,'Units','Characters',...
    'Title',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:PlotCollectionMembers')),'tag','tsplot','vis','on');
h.NewPlotPanel = tsguis.newplotpanel;
h.NewPlotPanel.initialize(h.Handles.pnlPlot, manager, h, 'tscollection');
set(h.Handles.pnlPlot,'ResizeFcn',{@localPlotResize h.NewPlotPanel.Panel});

function localRemoveTsNode(~,ed,h)

if strcmp(ed.Type,'ObjectChildRemoved')
    h.updatePanel(ed.Child);
end

%--------------------------------------------------------------------------
function localExtractTs(~,~,this)

% Extract the selected timeseries members to the parent Time Series node as
% a flat list.

selectedRows = this.Handles.membersTable.getSelectedRows+1;

for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>0
        tableData = cell(this.Handles.membersTable.getModel.getData);
        tsName = tableData{selRow,1};
        if isempty(tsName) %no members
            return
        end    
        ts = this.Tscollection.tsValue.getts(tsName);
        if ~isempty(ts)
            newname = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Copy_of_', ts.Name));
            k = 2;
            G = this.getParentNode.getChildren;
            for n = 1:length(G)
                if isa(G(n),'tsguis.tsnode') && strcmp(newname,G(n).Label)
                    newname = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Copy_Number_Of',k,ts.Name));
                    k = k+1;
                end
            end
            ts.Name = newname;
            childnode = ts.createTstoolNode(this.up);
            if ~isempty(childnode)
                childnode = this.up.addNode(childnode);
            end
        end
    end
end

%--------------------------------------------------------------------------
function localTsCollNameChange(es,~,varargin)
% Update the Name text on the panel when the tscollectionNode name is
% changed. 

set(es.Handles.PNLTsOuter,'Title', [getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeSeriesCollection')),get(es,'Label')]);
es.up.updatePanel('child_rename'); %update the name in the table of the parent node.

%--------------------------------------------------------------------------
function localDeleteTimeSamples(~,~,h)
% delete selected time samples from the tscollection time vector


hT = h.Handles.timeTable;
selrow = hT.Table.getSelectedRows;

if ~isempty(selrow)
    T = tsguis.transaction;
    T.ObjectsCell = {h.Tscollection};
    recorder = tsguis.recorder;

    % delete the selected samples from tscollection
    %h.Tscollection.delSample('index',selectedRows);
    delrow(hT);

    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%%%% ' getString(message('MATLAB:timeseries:tsguis:tscollectionNode:DeleteSelectedSamplesFromTscollection', ...
            genvarname(h.Tscollection.Name))) ]);
        T.addbuffer(sprintf('%s = delsamplefromcollection(%s,''index'',[%s])',...
            genvarname(h.Tscollection.Name),genvarname(h.Tscollection.Name), num2str(selrow(:)'+1)),...
            h.Tscollection);
    end

    %% Store transaction
    T.commit;
    recorder.pushundo(T);
end


%--------------------------------------------------------------------------
function localInsertTimeSample(~,~,h)

h.Handles.timeTable.addrow;

%--------------------------------------------------------------------------
function localChildAdded(~,ed,this)

updatePanel(this);

ed.Child.HelpFile = 'ts_collection_member_cpanel';

function localEditTimeResize(es,~,h)

pos = get(es,'Position');

set(h.Handles.currentTimeInfo,'Position',[1 5 pos(3)-4 2]);
set(h.Handles.PNLtimeTable,'Position',[2 8 pos(3)-4 pos(4)-10]);
set(h.Handles.addBtn,'Position',[pos(3)-13 3 10 1.5]);
set(h.Handles.deleteBtn,'Position',[pos(3)-24 3 10 1.5]);
set(h.Handles.newTimeBtn,'Position',[pos(3)-28 1 25 1.5]);

function localMembersResize(es,~,h)

pos = get(es,'Position');

set(h.Handles.membersTableContainer,'Position',[2 3.5 pos(3)-5 pos(4)-5.4]);
set(h.Handles.extractBtn,'Position',[pos(3)-14 1 10 1.5]);
set(h.Handles.removeBtn,'Position',[pos(3)-25 1 10 1.5]);
set(h.Handles.importBtn,'Position',[pos(3)-36 1 10 1.5]);


function localPanelResize(es,~,h)

pos = get(es,'Position');

set(h.Handles.pnlPlot,'Position',[1 1 pos(3)-3 7.5]);
set(h.Handles.pnlMembers,'Position',[1 8.5 pos(3)*.6-3 pos(4)-9]);
set(h.Handles.pnlTimeInfo,'Position',[pos(3)*.6-1 8.5 pos(3)*.4-1 pos(4)-9]);

function localPlotResize(es,~,plotPanel)

pos = get(es,'Position');
set(plotPanel,'Position',[1 1 pos(3)-2 pos(4)-2]);

function localShowTimeReset(~,~,h)

import com.mathworks.toolbox.timeseries.*;

tsguis.tsUniformTimeDlg(h,'open')

function localDelete(~,~,h)

delete(get(h,'TimeResetPanel'))

function localimportTsCallback(~,~,h)

importTsCallback(h);

function localremoveTsCallback(~,~,h)

removeTsCallback(h);