function Panel = getDialogSchema(this, manager)

%   Copyright 2004-2013 The MathWorks, Inc.


import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this);

%% Install listeners which update the timeseries table
this.addListeners([ ...
    handle.listener(this,'ObjectChildAdded',{@localUpdatePanel this}); ...
    handle.listener(this,'ObjectChildRemoved',{@localRemoveTsNode this})]);
    
set(this.Handles.PNLTs,'Visible','on')

function localUpdatePanel(~,~,h)

updatePanel(h);

%--------------------------------------------------------------------------
function f = localBuildPanel(thisfig,h)

%% Create and position the components on the panel
 
import javax.swing.*;

%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off'); 

%% Build child timeseries panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Characters','Title',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeries')), ...
    'Visible','off');

%header info
h.tstable
set(h.Handles.PNLtsTable,'Units','Normalized','Parent',h.Handles.PNLTs,'Position',[.03 .1 .94 .88]);
uicontrol('Style','Pushbutton','String', ...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:Remove')), ...
    'Parent',h.Handles.PNLTs,...
    'Units','Characters','Callback',{@localRemoveTs h},'Position',[3 1 12 1.5],'Tag','TSBTNremove');

%% Assign and call the panel resize fcn
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTs})
localFigResize(f,[],h.Handles.PNLTs)

%--------------------------------------------------------------------------
function localRemoveTsNode(~,ed,h)

if strcmp(ed.Type,'ObjectChildRemoved')
    h.updatePanel(ed.Child);
end

%--------------------------------------------------------------------------
function localRemoveTs(~,~,this)

%% Remove ts callback

selectedRows = this.Handles.tsTable.getSelectedRows+1;
tsNodes = {};
for k = 1:length(selectedRows)
    selRow = selectedRows(k);
    if selRow>0
        tableData = cell(this.Handles.tsTable.getModel.getData);
        tsName = tableData{selRow,1};
        tsNodes{end+1} = this.getChildren('Label',tsName); %#ok<AGROW>
    end
end

for k = 1:length(tsNodes)
    tsNode = tsNodes{k};
    if ~isempty(tsNode)
        this.removeNode(tsNode); % Listeners will update the table
        % Must call drawnow here to prevent test failures due to events
        % order processing issues when deleting multiple rows (g564814)
        drawnow
    end
end

%clear selection
awtinvoke(this.Handles.tsTable,'clearSelection');
%--------------------------------------------------------------------------
function localFigResize(es,ed,PNLts)

%% Resize callback for tsparentnode panel

%% No-op if the panel is invisible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Characters',get(es,'Parent'));

%% Set the tstable panel to take up all the space above the import panel
set(PNLts,'Position',[2 1.4 max(1,mainpnlpos(3)-4) max(1,mainpnlpos(4)-2.4)]);

