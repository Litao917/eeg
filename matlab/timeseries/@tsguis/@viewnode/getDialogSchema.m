function Panel = getDialogSchema(this, manager)

% Copyright 2004-2012 The MathWorks, Inc.

import javax.swing.*;

%% Create the node panel and components
Panel = localBuildPanel(manager.Figure,this,manager);

%% Listener to keep the time series table synched with the view
this.addListeners(handle.listener(this,'tschanged',{@localTstable this}));

%% Show the panel
set(this.Handles.PNLTs,'Visible','on')
figure(double(manager.Figure))

function f = localBuildPanel(thisfig,h,manager)

%% Create and position the components on the panel
 
%% Build upper combo and label
f = uipanel('Parent',thisfig,'Units','Normalized','Visible','off');

%% Build time series panel
h.Handles.PNLTs = uipanel('Parent',f,'Units','Pixels','Title', ...
    getString(message('MATLAB:timeseries:tsguis:viewnode:DefineDisplayedTimeSeries')), ...
    'Visible','off');
h.tstable;
h.Handles.BTNremoveTs = uicontrol('Style','pushbutton','Parent', ...
    h.Handles.PNLTs,'Units','Pixels','String', ...
    getString(message('MATLAB:timeseries:tsguis:viewnode:RemoveTimeSeriesFromView')),...
    'Callback',{@localRmTimeseries h});
h.Handles.BTNEditView = uicontrol('Style','pushbutton','Parent', ...
    h.Handles.PNLTs,'Units','Pixels','String', ...
    getString(message('MATLAB:timeseries:tsguis:viewnode:EditPlot')),...
    'Callback',{@localEditView h});
set(h.Handles.PNLTs,'ResizeFcn',{@PNLTsResize ...
    h.Handles.BTNremoveTs h.Handles.BTNEditView h.Handles.PNLTsTable})
PNLTsResize(h.Handles.PNLTs,[],h.Handles.BTNremoveTs,h.Handles.BTNEditView,...
    h.Handles.PNLTsTable);

%% Resize behavior
set(f,'ResizeFcn',{@localFigResize h.Handles.PNLTs});
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resize functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function PNLTsResize(es,~,BTNremoveTs,BTNEditView,PNLTsTable)

%% Resize fcn for the time series pane;

%% Get sizes and margins
pos = get(es,'Position');
margin = 10;

%% Set positions
btnSize = get(BTNremoveTs,'Extent');
rmBtnSize = [max(1,pos(3)-btnSize(3)-margin-18) margin btnSize(3)+18 btnSize(4)];
set(BTNremoveTs,'Position',rmBtnSize)
btnSize = get(BTNEditView,'Extent');
set(BTNEditView,'Position',[max(1,rmBtnSize(1)-margin-btnSize(3)-18) margin btnSize(3)+18 btnSize(4)])
set(PNLTsTable,'Position', ...
    [margin btnSize(4)+2*margin max(1,pos(3)-2*margin) ...
         max(1,pos(4)-(btnSize(4)+2*margin)-2*margin)])



function localFigResize(es,ed,PNLTs)

%% Resize callback for view panel

%% No-op if the panel is invisible or if there is no eventData passed with
%% the firing resize event
if strcmp(get(es,'Visible'),'off') && isempty(ed)
    return
end

gap = 3; % Interpanel gap
timePanelHeight = 141;

%% Components and panels are repositioned relative to the main panel
mainpnlpos = hgconvertunits(ancestor(es,'figure'),get(es,'Position'),get(es,'Units'),...
    'Pixels',get(es,'Parent'));

%% Set the time series panel to take up all the space horizontally
%% and 1/3 of the available vertical space
pnlpos = hgconvertunits(ancestor(PNLTs,'figure'),...
    [10 10 max(1,mainpnlpos(3)-20) max(1,mainpnlpos(4)-20)],'Pixels',...
    get(PNLTs,'Units'),get(PNLTs,'Parent'));
set(PNLTs,'Position',pnlpos);

function localRmTimeseries(~,~,h)

%% Remove time series button callback
selectedRow = h.Handle.tsTable.getSelectedRow+1;
if selectedRow>0
    h.removets(h.Plot.waves(selectedRow));
end

function localEditView(~,~,this)

%% Edit view button callback which detaches Opens the PlotTool 
%% Property Editor
if ~isempty(this.Plot) && ishandle(this.Plot)
    propedit(this.Plot.AxesGrid.Parent);
else
    errordlg(getString(message('MATLAB:timeseries:tsguis:viewnode:PlotIsEmpty')),...
        getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesTools')), ...
        'modal')
end

function localTstable(~,~,h)

tstable(h)