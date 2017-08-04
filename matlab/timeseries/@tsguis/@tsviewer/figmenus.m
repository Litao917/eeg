function figmenus(this)
%figure menus for tstool

%   Copyright 2004-2013 The MathWorks, Inc.

%% Create toolbar
htoolbar = uitoolbar(this.TreeManager.Figure,'HandleVisibility','off');


%%%%%%%%%%%%%%%%%%%% File menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileMenu = uimenu('Parent',this.TreeManager.Figure,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:File')), ...
    'Tag', 'ts.File');
ic1 = fullfile(matlabroot,'toolbox','matlab','timeseries','import_ml_data.gif'); %#ok<MCTBX,MCMLR>
uipushtool(htoolbar,'Tooltip', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ImportTimeSeriesOrCollectionObject')),...
    'CData',localGetIcon(ic1,72),'ClickedCallback',{@localAddTS this});

%% File - Import Menu
importMenu = uimenu('Parent',fileMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ImportFromWorkspace')),...
    'Tag', 'ts.ImportFromWorkspace');
uimenu('Parent',importMenu,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ArrayData')), ...
    'Callback', {@localImport this getString(message('MATLAB:timeseries:tsguis:tsviewer:MATLABWorkspace'))}, 'Tag', 'ts.ArrayData');
uimenu('Parent',importMenu,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesObjectsOrCollections')), ...
    'Callback',{@localAddTS this}, 'Tag', 'ts.tsObjects');
uimenu('Parent',fileMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:CreateTimeSeriesFromFile')),...
    'Callback', {@localImport this getString(message('MATLAB:timeseries:tsguis:tsviewer:ExcelWorkbookxls'))}, ...
    'Tag','ts.ImportFromFile');

% Simulink Data import pushtool and import option
ic3 = fullfile(matlabroot,'toolbox','matlab','timeseries','import_data.gif'); %#ok<MCTBX,MCMLR>
uipushtool(htoolbar,'Tooltip', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:CreateTimeSeriesFromFileOrWorkspaceData')),...
    'CData',localGetIcon(ic3,24),...
    'ClickedCallback',{@localImport this getString(message('MATLAB:timeseries:tsguis:tsviewer:ExcelWorkbookxls'))});

%% File - Export submenu
exportMenu = uimenu('Parent',fileMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Export')),'Tag','ts.export');
uimenu('Parent',exportMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ToFile')), ...
    'Callback',{@localFileExport this}, 'Tag', 'ts.ToFile');
uimenu('Parent',exportMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ToWorkspace')), ...
    'Callback',{@localWorkspaceExport this}, 'Tag', 'ts.ToWorkspace');

%% File - macro recorder
recorder = tsguis.recorder;
uimenu('Parent',fileMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:RecordCode')),...
    'Separator','on','Callback',@(es,ed) edit(recorder,this.TreeManager.Figure), 'Tag', 'ts.RecordMcode');

%% File - close submenu
uimenu('Parent',fileMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Close')), ...
    'Separator','on',...
    'Callback',@(es,ed) delete(get(this,'TreeManager')), 'Tag', 'ts.Close');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Edit menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
editMenu = uimenu('Parent',this.TreeManager.Figure,'Label',getString(message('MATLAB:timeseries:tsguis:tsviewer:Edit')),'Tag','ts.edit', 'Tag', 'ts.Edit');

%% Edit Undo and Redo menus and toolbar
undoMenu = uimenu('Parent',editMenu,'Label',getString(message('MATLAB:timeseries:tsguis:tsviewer:Undo')),'Callback', ...
    @localUndo,'Tag','ts.undo','Interruptible',...
    'off','BusyAction','cancel');
redoMenu = uimenu('Parent',editMenu,'Label',getString(message('MATLAB:timeseries:tsguis:tsviewer:Redo')),'Callback',...
    @localRedo,'Tag','ts.redo','Interruptible',...
    'off','BusyAction','cancel');
load(fullfile(matlabroot,'toolbox','matlab','icons','undo.mat')); %#ok<MCMLR,MCTBX>
undoTB = uipushtool(htoolbar,'Tooltip',getString(message('MATLAB:timeseries:tsguis:tsviewer:UndoDataChange')),...
    'Tag','ts.undo','CData',undoCData,...
    'ClickedCallback',@localUndo,'Interruptible',...
    'off','BusyAction','cancel');
load(fullfile(matlabroot,'toolbox','matlab','icons','redo.mat')); %#ok<MCTBX,MCMLR>
redoTB = uipushtool(htoolbar,'Tooltip',getString(message('MATLAB:timeseries:tsguis:tsviewer:RedoDataChange')),...
    'Tag','ts.redo','CData',redoCData,...
    'ClickedCallback',@localRedo,'Interruptible',...
    'off','BusyAction','cancel');
r = tsguis.recorder;
L = [handle.listener(r,r.findprop('Undo'),'PropertyPostSet',...
       {@setUndoStatus undoMenu undoTB r});...
     handle.listener(r,r.findprop('Redo'),'PropertyPostSet',...
       {@setRedoStatus redoMenu redoTB r})];
this.Listeners = [this.Listeners; L];
setUndoStatus([],[],undoMenu,undoTB,r)
setRedoStatus([],[],redoMenu,redoTB,r)

%% Copy menu
copyMenu = uimenu('Parent',editMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Copy')), ...
    'Separator','on',...
    'Callback',{@localCopy this},'Tag','ts.copy');

%% Copy toolbar button
copyTB = uipushtool(htoolbar,'Tooltip', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:CopyTimeSerieObject')),...
    'Tag','ts.copy','CData',localGetIcon('copy.gif',8),...
    'ClickedCallback',{@localCopy this});

%% Paste toolbar button
pasteTB = uipushtool(htoolbar,'Tooltip', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:PasteTimeSerieObject')),...
    'Tag','ts.paste','CData',localGetIcon('paste.gif',58),...
    'ClickedCallback',{@localPaste this this.TreeManager},'Interruptible',...
    'off','BusyAction','cancel');

%% Paste menu
pasteMenu = uimenu('Parent',editMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Paste')), ...
    'Callback',...
    {@localPaste this this.TreeManager},'Tag','ts.paste','Interruptible',...
    'off','BusyAction','cancel');

%% Paste action listeners
this.Listeners = [this.Listeners;...
     handle.listener(this,this.findprop('Clipboard'),'PropertyPostSet',...
     {@localClipBoardUpdate this pasteMenu pasteTB})];
localClipBoardUpdate([],[],this,pasteMenu,pasteTB)

%% Edit - delete menu
deleteMenu = uimenu('Parent',editMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Remove')), ...
    'Separator','on',...
    'Callback',{@localDelete this},'Tag','ts.delete','Interruptible',...
    'off','BusyAction','cancel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataMenu = uimenu('Parent',this.TreeManager.Figure,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Data')),...
    'Tag','ts.data');

%% Data - manipulation submenus
selectionMenu = uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:SelectDataOnTimePlot')), ...
    'Callback', {@localDataSelect this},'Tag','ts.select');
uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:RemoveMissingData')), ...
    'Callback', {@localPreproc this},'Tag','ts.remove');
uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Detrend')), ...
    'Callback', {@localPreproc this },'Tag','ts.detrend');
uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Filter')), ...
    'Callback', {@localPreproc this},'Tag','ts.filter');
uimenu('Parent',dataMenu,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Interpolate')), ...
    'Callback', {@localPreproc this},'Tag','ts.interp');

mergeMenu = uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Resample')), ...
    'Callback', {@localMerge this},'Tag','ts.merge','Separator','on');
%% Data - Arithmetic
matlabMenu = uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:TransformAlgebraically')), ...
    'Callback', {@localArith this},'Tag','ts.arith');
shiftMenu = uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Synchronize')), ...
    'Callback', {@localTimeShift this},'Tag','ts.shift'); 

%% Data - stats submenu
statsMenu = uimenu('Parent',dataMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:DescriptiveStatistics')),...
    'Callback',{@localOpenStats this.Tsnode this.TreeManager},...
    'Separator','on','Tag','ts.descriptive');

%% Plot menu - note xlate does not seem to work in anon fcns
plotMenu = uimenu('Parent',this.TreeManager.Figure,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Plot')), ...
    'Tag', 'ts.Plot');
newPlotMenu = uimenu('Parent',plotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:NewPlot')), ...
    'Tag', 'ts.NewPlot');
timePlotStr = getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimePlots'));
uimenu('Parent',newPlotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:TimePlot')), ...
    'Callback',@(es,ed) addPlot(this,timePlotStr), 'Tag', 'ts.TimePlot');
specPlotStr = getString(message('MATLAB:timeseries:tsguis:viewcontainer:SpectralPlots'));
uimenu('Parent',newPlotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:SpectralPlot')), ...
    'Callback',@(es,ed) addPlot(this,specPlotStr), 'Tag', 'ts.SpectralPlot');
xyPlotStr = getString(message('MATLAB:timeseries:tsguis:viewcontainer:XYPlots'));
uimenu('Parent',newPlotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:XYPlot')), ...
    'Callback',@(es,ed) addPlot(this,xyPlotStr), 'Tag', 'ts.XYPlot');
corrPlotStr = getString(message('MATLAB:timeseries:tsguis:viewcontainer:Correlations'));
uimenu('Parent',newPlotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:CorrelationPlot')), ...
    'Callback',@(es,ed) addPlot(this,corrPlotStr), 'Tag', 'ts.CorrelationPlot');
histPlotStr = getString(message('MATLAB:timeseries:tsguis:viewcontainer:Histograms'));
uimenu('Parent',newPlotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Histogram')), ...
    'Callback',@(es,ed) addPlot(this,histPlotStr), 'Tag', 'ts.Histogram');

%% Help menu
helpMenu = uimenu('Parent',this.TreeManager.Figure,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:Help')));
helpCSH = uimenu('Parent',helpMenu,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ContextSensitiveHelp')),...
    'Callback',{@localToggleCSH this},'Tag','CSHmenu','Checked','on','Separator',...
    'on');
uimenu('Parent',helpMenu,'Label',...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:AboutMATLAB')),...
    'Callback',...
    @(es,ed) helpmenufcn(this.TreeManager.Figure,'HelpAbout'),...
    'Separator','on'); 


%% Create the context sensitive help toolbar button
ic = fullfile(matlabroot,'toolbox','matlab','timeseries','help_context.gif'); %#ok<MCTBX,MCMLR>
tbbtnCSH = uitoggletool(htoolbar,'Tooltip', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:DispContextHelp')),...
    'Tag','DispContextHelp','CData',localGetIcon(ic,99),'Tag','CSHtool');
set(tbbtnCSH,'State','on','OnCallback',...
    @(es,ed) set(get(this,'TreeManager'),'HelpShowing','on'),...
    'offcallback', @(es,ed) set(get(this,'TreeManager'),'HelpShowing','off'),...
    'TooltipString', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:ShowHideContextSensitiveHelp')));
this.Listeners = [this.Listeners;...
     handle.listener(this.TreeManager,this.TreeManager.findprop('HelpShowing'),...
     'PropertyPostSet',{@localCSHListenerCallback this})];
%line styles ..
uimenu('Parent',plotMenu,'Label', ...
    getString(message('MATLAB:timeseries:tsguis:tsviewer:SetLineProperties')),...
    'Callback',{@localLineStyle this},...
    'Tag', 'ts.Set Line Properties...');

%====
%% Exclude undo/redo who's enabled status is set by listeners to the 
%% @recorder object
this.TreeManager.Menus = [fileMenu; copyMenu; deleteMenu;...
    plotMenu; dataMenu;mergeMenu; exportMenu; ...
    selectionMenu; shiftMenu; matlabMenu; statsMenu; helpCSH];
this.TreeManager.ToolbarButtons = [copyTB;tbbtnCSH];
%====

%--------------------------------------------------------------------------
function localAddTS(~,~,h)

h.TSnode.createChild;


%--------------------------------------------------------------------------
function localLineStyle(~,~,this)
%

if isempty(this.StyleDlg) || ~ishghandle(this.StyleDlg)
   % Create style dialog
   this.StyleDlg = styledlg(this);
   this.Listeners = [this.Listeners; ...
        handle.listener(this,'ObjectBeingDestroyed',...
        {@localCloseStyleDlg this})];
else
   % Bring it up front
   set(this.StyleDlg,'Visible','on');
end

%--------------------------------------------------------------------------
function localCopy(~,~,this)

%% Copy the currently selected node to the @tsviewer clipboard if it is a
%% @tsnode or a @viewnode
selectednode = this.Treemanager.getselectednode;
if isa(selectednode,'tsguis.tsnode') || isa(selectednode,'tsguis.viewnode') ||...
        isa(selectednode,'tsguis.tscollectionNode')
     this.Clipboard = selectednode;
end

%--------------------------------------------------------------------------
function localPaste(~,~,this,manager)

%% Paste the clipboard to the currently selected node in the @tsviewer
selectednode = this.Treemanager.getselectednode;
if ~isempty(selectednode)
    selectednode.paste(manager);
end

%--------------------------------------------------------------------------
function localDelete(~,~,this)

thisnode = this.TreeManager.getselectednode;
manager = this.TreeManager;

%% Only @viewnodes and @tsnodes can be deleted
if isa(thisnode,'tsguis.viewnode') && ~isempty(thisnode.up)
    % Select the root so the deleted node is not selected
    this.TreeManager.reset
    this.TreeManager.Tree.setSelectedNode(thisnode.getRoot.down.getTreeNodeInterface);
    drawnow % Force the node to show selected
    this.TreeManager.Tree.repaint
    thisnode.up.removeNode(thisnode)
    return
end

% check if the member being removed belongs to a collection (no need to
% check if it is a time series, since it must be for the test below to pass)
if strcmp(class(thisnode.up),'tsguis.tscollectionNode')
    % timeseries chosen for deletion belongs to a tscollection
    manager.reset
    manager.Tree.setSelectedNode(thisnode.up.getTreeNodeInterface);
    drawnow % Force the node to show selected
    manager.Tree.repaint
    %Record the remove-ts transaction
    T = tsguis.nodetransaction;
    recorder = tsguis.recorder;
    T.ObjectsCell = {thisnode.Timeseries};
    T.Action = 'removed';
    T.ParentNodeHandle = thisnode.up;

    thisnode.up.Tscollection.removets(thisnode.Timeseries.Name);

    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:tsviewer:DeleteTscollectionMember'))]);
        T.addbuffer([genvarname(thisnode.up.Tscollection.Name),...
            ' = removets(',genvarname(thisnode.up.Tscollection.Name),', ',...
            genvarname(thisnode.Timeseries.Name),');'],thisnode.up.Tscollection);
    end

    %% Store transaction
    T.commit;
    recorder.pushundo(T);

    return
end

if (strcmp(class(thisnode),'tsguis.tsnode') && ~isempty(thisnode.up)) 
    remove(thisnode,manager);
end



%--------------------------------------------------------------------------
function localTimeShift(~,~,this)

%% Time shift menu callback to open the time shift dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openshift on it
if ~isempty(thisnode)
    try
        thisnode.openshiftdlg(this.Treemanager)
    catch %#ok<CTCH>
        msg = getString(message('MATLAB:timeseries:tsguis:tsviewer:NoSynchronizeTimeSeriesDialog',...
            thisnode.Label));
        errordlg(msg, ...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
            'modal')
        return    
    end
end

%--------------------------------------------------------------------------
function localDataSelect(~,~,this)

%% Data select menu callback to open the date select dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        thisnode.openselectdlg(this.Treemanager)
    catch         %#ok<CTCH>
        msg = getString(message('MATLAB:timeseries:tsguis:tsviewer:NoSelectDataDialog',...
            thisnode.Label));
        errordlg(msg,...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
            'modal')
        return    
    end
end

%-------------------------------------------------------------------------
function localMerge(~,~,this)

%% Merge menu callback to open the merge dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        tsguis.datamergedlg(thisnode);
    catch %#ok<CTCH>
        msg = getString(message('MATLAB:timeseries:tsguis:tsviewer:NoResampleDialog',...
            thisnode.Label));
        errordlg(msg, ...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
            'modal')
        return        
    end
end

%--------------------------------------------------------------------------
function localPreproc(eventSrc,~,this)

%% Preprocessing callback to open the preproc dialog

tag = get(eventSrc,'Tag');
switch tag
    case 'ts.remove'
        Ind = 4;
    case 'ts.detrend'
        Ind = 1;
    case 'ts.filter'
        Ind = 2;
    case 'ts.interp'
        Ind = 3;
    otherwise
        Ind = 1;
end

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        if isa(thisnode,'tsguis.viewnode')
            RS = tsguis.preprocdlg(thisnode);
        else
            RS = tsguis.datapreprocdlg(thisnode);
        end
        set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);
    catch %#ok<CTCH>
        msg = getString(message('MATLAB:timeseries:tsguis:tsviewer:NoProcessDataDialog',...
            thisnode.Label));
        errordlg(msg, ...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
            'modal')
        return
    end
end

%--------------------------------------------------------------------------
function localArith(~,~,this)

%% MATLAB expression callback to open the arithmetic dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openarithdlg on it
if ~isempty(thisnode)
    try
        thisnode.openarithdlg(this.TreeManager)
    catch %#ok<CTCH>
        msg = getString(message('MATLAB:timeseries:tsguis:tsviewer:NoTransformAlgebraicallyDialog',...
            thisnode.Label));
        errordlg(msg, ...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')), ...
            'modal')
        return
    end
end


% -----------------------------------------------------------------------
% for importing
% -----------------------------------------------------------------------
function localImport(~,~,this,varargin)

importWizard = tsguis.ImportWizard(this);
if nargin>=4
    importOptions = get(importWizard.Handles.COMBsource,'String');
    ind = find(strcmp(importOptions,varargin{1})); 
    if ~isempty(ind)
       cb = get(importWizard.Handles.COMBsource,'Callback');
       set(importWizard.Handles.COMBsource,'Value',ind(1));
       feval(cb{1},[],[],cb{2:end});
    end
end


% -----------------------------------------------------------------------
% for exporting
% -----------------------------------------------------------------------
function localFileExport(~,~,this)

% Open export for selected time series node
node = this.TreeManager.getselectednode;
if isa(node,'tsguis.tsparentnode')
    node.exportSelectedObjects(2,this.TreeManager);
else  
    dlg = tsguis.allExportdlg;
    dlg.initialize('file',this.TreeManager.Figure,{node});
end

%--------------------------------------------------------------------------
function localWorkspaceExport(~,~,this)
%% export this timeseries object to workspace
node = this.TreeManager.getselectednode;
% note: don't change the order, since tsguis.simulinkTsNode is a child of tsguis.tsnode
if isa(node,'tsguis.tsnode') || isa(node,'tsguis.tscollectionNode')
    list = evalin('base','whos;');
    flag = false;
    if isa(node,'tsguis.tsnode')
        newName = genvarname(node.Timeseries.Name);
    elseif isa(node,'tsguis.tscollectionNode')
        newName = genvarname(node.Tscollection.Name);
    end
    for i=1:length(list)
        if strcmp(list(i).name,newName)
            flag = true;
            break;
        end
    end
    if (isa(node,'tsguis.tsnode') && ~strcmp(node.Timeseries.name,newName)) || ...
            (isa(node,'tsguis.tscollectionNode') && ~strcmp(node.Tscollection.name,newName))
        warning(message('MATLAB:tsguis:tsviewer:figmenus:InvalidObjectName', newName));
    end
    if flag
        if isa(node,'tsguis.tsnode')
            ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeseriesObjectAlreadyExists')),...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:DuplicatedVariableDetected')), ...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Overwrite')),...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Abort')),...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Overwrite')));
        elseif isa(node,'tsguis.tscollectionNode')
            ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsviewer:TscollectionObjectAlreadyExists')),...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:DuplicatedVariableDetected')),...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Overwrite')), ...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Abort')), ...
                getString(message('MATLAB:timeseries:tsguis:tsviewer:Overwrite')));           
        end
        switch ButtonName,
            case getString(message('MATLAB:timeseries:tsguis:tsviewer:Overwrite'))
                if isa(node,'tsguis.tsnode') 
                    assignin('base',newName,node.Timeseries.TsValue);
                elseif isa(node,'tsguis.tscollectionNode')
                    assignin('base',newName,node.Tscollection.TsValue);
                end
            case getString(message('MATLAB:timeseries:tsguis:tsviewer:Abort'))
                return
        end
    else
        if isa(node,'tsguis.tsnode')
            assignin('base',newName,node.Timeseries.TsValue);
        elseif isa(node,'tsguis.tscollectionNode')
            assignin('base',newName,node.Tscollection.TsValue);
        end
        msgbox(getString(message('MATLAB:timeseries:tsguis:tsviewer:ObjectWasExportedToTheBaseWorkspace', ...
            newName)),...
            getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
            'modal');
    end
elseif isa(node,'tsguis.tsparentnode')
    node.exportSelectedObjects(3,this.TreeManager);
else
    return
end

%--------------------------------------------------------------------------
function localOpenStats(~,~,h,manager)

dlg = tsguis.statsdlg(h,manager);
dlg.Visible = 'on';

%--------------------------------------------------------------------------
function setUndoStatus(~,~,undoMenu,undoTB,r)

%% Recorder Undo stack listener callback
if isempty(r.Undo)
    set(undoMenu,'Enable','off')
    set(undoTB,'Enable','off')
else
    set(undoMenu,'Enable','on')
    set(undoTB,'Enable','on')
end

%--------------------------------------------------------------------------
function setRedoStatus(~,~,redoMenu,redoTB,r)

%% Recorder Redo stack listener callback
if isempty(r.Redo)
    set(redoMenu,'Enable','off')
    set(redoTB,'Enable','off')
else
    set(redoMenu,'Enable','on')
    set(redoTB,'Enable','on')
end

%--------------------------------------------------------------------------
function localClipBoardUpdate(~,~,this,pasteMenu,pasteTB)

%% Callback to clipboard listener
if ~isempty(this.Clipboard) && ...
        isa(this.Clipboard,class(this.TreeManager.getselectednode))
    set(pasteMenu,'Enable','on')
    set(pasteTB,'Enable','on')
else
    set(pasteMenu,'Enable','off')
    set(pasteTB,'Enable','off')
end
        
%--------------------------------------------------------------------------
function cdata = localGetIcon(thispath,I)

%% Get the icon for the data selection toolbar button
[cdata,map] = imread(thispath);

% Set all white (1,1,1) colors to be transparent (nan)
ind = (map(:,1)+map(:,2)+map(:,3)==3);
map(ind,:) = nan;
if nargin>1
    % required by some icons, where the last non-black color takes over all
    % the trailing black values in the map
    map(I,:) = nan;
end
cdata = ind2rgb(cdata,map);

%--------------------------------------------------------------------------
function localUndo(es,ed) %#ok<INUSD>

r = tsguis.recorder;
undo(r);

%--------------------------------------------------------------------------
function localRedo(es,ed) %#ok<INUSD>

r = tsguis.recorder;
redo(r);

function localCloseStyleDlg(~,~,this)

if ~isempty(this.StyleDlg) && ishghandle(this.StyleDlg)
    delete(this.StyleDlg);
end

function localToggleCSH(~,~,h)

%% Toggle the state of the CSH panel
if strcmp(h.TreeManager.HelpShowing,'off')    
    h.TreeManager.HelpShowing = 'on';
else
    h.TreeManager.HelpShowing = 'off';
end

function localCSHListenerCallback(~,~,h)

%% Listener callback for changes in the HelpShowing property of the
%% TreeManager
m = findobj(h.TreeManager.Menus,'Tag','CSHmenu');
if ~isempty(m)
    set(m,'Checked',get(h.TreeManager,'HelpShowing'));
end
tb = findobj(h.TreeManager.ToolbarButtons,'Tag','CSHtool');
if ~isempty(tb)
    set(tb,'State',get(h.TreeManager,'HelpShowing'));
end