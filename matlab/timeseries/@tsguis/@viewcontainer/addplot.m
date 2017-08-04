function h = addplot(this,manager,varargin)

%   Copyright 2004-2012 The MathWorks, Inc.

%% Add an empty plot node and creates an invisible undocked figure to
%% contain it. The figure must be invisible so that time series can be
%% added to it by calling functions without creating a flicker. If no time
%% series are added, calling functions must set the figure visible and dock
%% it themselves.

set(manager.figure,'Pointer','watch')

%% Build figures
f = figure('Visible','off', 'NumberTitle','off','HandleVisibility','callback',...
    'IntegerHandle','off', 'Tag', 'addplot');
viewer = tsguis.tsviewer;
if viewer.DataTipsEnabled
    set(f,'WindowButtonMotionFcn',@hoverfig);
end
deletemenubytag(f,'figMenuInsert');
deletemenubytag(f,'figMenuOpen');
deletemenubytag(f,'figMenuFileSaveWorkspaceAs');
deletemenubytag(f,'figMenuMFileSaveAs');
deletemenubytag(f,'figMenuFileImportData');
deletemenubytag(f,'figMenuRotate3D');
deletemenubytag(f,'figMenuFileSaveAs');
deletemenubytag(f,'figMenuFileSave');
deletemenubytag(f,'figMenuEditClear');
deletemenubytag(f,'figMenuEditPaste');
deletemenubytag(f,'figMenuEditCopy');
deletemenubytag(f,'figMenuEditCut');
deletemenubytag(f,'figMenuEditGCA');
deletemenubytag(f,'figMenuEditGCF');
deletemenubytag(f,'figBrush');
deletemenubytag(f,'figLinked');
deletemenubytag(f,'figDataManagerBrushTools');

   
viewer = tsguis.tsviewer;
if ~viewer.DataTipsEnabled
    deletemenubytag(f,'figMenuDatatip');
    delete(uigettool(f,'Exploration.DataCursor'))
    delete(uigettool(f,'Standard.SaveFigure'))
    delete(uigettool(f,'Exploration.Brushing'))
    delete(uigettool(f,'DataManager.Linking'))
end

mdiGroupName = this.getRoot.Tsviewer.MDIGroupName;
if ~isempty(mdiGroupName)
    jf = tsguis.getJavaFrame(f);   
    drawnow % Figure must be fully built before setting the frame 
    jf.setGroupName(mdiGroupName);
end

%% Create view objects
switch this.Label
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimePlots'))
        h  = tsguis.tsseriesview;
        namePrefix = getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimePlot'));
        thishelpfile = 'plots_time';
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:SpectralPlots'))
        h  = tsguis.tsspecnode;
        namePrefix = getString(message('MATLAB:timeseries:tsguis:viewcontainer:SpectralPlot'));
        thishelpfile = 'plots_spectral';
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:XYPlots'))
        h  = tsguis.tsxynode;
        namePrefix = getString(message('MATLAB:timeseries:tsguis:viewcontainer:XYPlot'));
        thishelpfile = 'plots_xy';
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:Correlations'))
        h  = tsguis.tscorrnode;
        namePrefix = getString(message('MATLAB:timeseries:tsguis:viewcontainer:CorrelationPlot'));   
        thishelpfile = 'plots_correlation';
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:Histograms'))
        h  = tsguis.tshistnode;
        namePrefix = getString(message('MATLAB:timeseries:tsguis:viewcontainer:Histogram'));    
        thishelpfile = 'plots_histogram';
end

%% Get the help file - use default if not found
h.HelpFile = thishelpfile;

%% Leaf node designation
h.AllowsChildren = false;

%% Build the view and set drop adapters
views = this.up.find('-depth',2);
if nargin>=3
    if ~isempty(views) && any(strcmpi(varargin{1},get(views,{'Label'})))
        uiwait(warndlg(getString(message('MATLAB:timeseries:tsguis:viewcontainer:TheSpecifiedNameConflicts')),...
            getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimeSeriesTools')),'modal'));
        ct = 1;
        newName = sprintf('%s_%d',varargin{1},ct);
        while any(strcmp(newName,get(views,{'Label'})))
            ct=ct+1;
            newName = sprintf('%s_%d',varargin{1},ct);
        end
        varargin{1} = newName;
    end
    h.initialize(manager,f,varargin{1});
    set(h.Figure,'Name',[namePrefix, ' ', varargin{1}]);
else
    ct = 1;
    while ~isempty(views) && any(strcmp(...
            getString(message('MATLAB:timeseries:tsguis:viewcontainer:ViewNumber',ct)),get(views,{'Label'})))
        ct = ct+1;
    end      
    h.initialize(manager,f,getString(message('MATLAB:timeseries:tsguis:viewcontainer:ViewNumber',ct)));
    set(h.Figure,'Name',[namePrefix, ' ',  ...
        getString(message('MATLAB:timeseries:tsguis:viewcontainer:ViewNumber',ct))]);
end

%% Does the new view have the right class
if ~strcmp(this.ChildClass,class(h))
    error(message('MATLAB:tsguis:viewcontainer:addplot:invChildClass'))
end

%% Add the node
newView = this.addNode(h);

%% Customize toolbar
h.Handles.Toolbar = findall(f,'Type','uitoolbar');
switch this.Label
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimePlots'))  
        modenames = {'DataSelect','TimeseriesTranslate','TimeseriesScale',...
            'TimeSelect'};
        gifnames = {'tsselect.gif','tstrans.gif','tsscale.gif','tstimeselect.gif'};
        tipstr = {getString(message('MATLAB:timeseries:tsguis:viewcontainer:SelectData')), ...
            getString(message('MATLAB:timeseries:tsguis:viewcontainer:MoveTimeSeries')),...
            getString(message('MATLAB:timeseries:tsguis:viewcontainer:RescaleTimeSeries')),...
            getString(message('MATLAB:timeseries:tsguis:viewcontainer:SelectTimeIntervals'))};
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:SpectralPlots'))
        modenames = {'IntervalSelect'};
        gifnames = {'tstimeselect.gif'};
        tipstr = {getString(message('MATLAB:timeseries:tsguis:viewcontainer:SelectFrequencyIntervals'))};
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:Histograms'))
        modenames = {'IntervalSelect'};
        gifnames = {'tsrangeselect.gif'};
        tipstr = {getString(message('MATLAB:timeseries:tsguis:viewcontainer:SelectYRangeInterval'))};
    case getString(message('MATLAB:timeseries:tsguis:viewcontainer:XYPlots'))
        modenames = {'DataSelect'};
        gifnames = {'tsselect.gif'};        
        tipstr = {getString(message('MATLAB:timeseries:tsguis:viewcontainer:SelectPoints'))};
    otherwise
        modenames = {};
        gifnames = {};        
        tipstr = {};
end

%% Assign on/off callbacks
for k=1:length(modenames)
    h.Handles.ToolbarBtns(k) = uitoggletool('Parent',h.Handles.Toolbar,...
               'Tag',modenames{k},'CData',localGetIcon(gifnames{k}));
    set(h.Handles.ToolbarBtns(k),'OnCallback',...
        {@localSetSelectmode h modenames{k}},'offcallback', ...
        {@localClearSelectmode h},'TooltipString',tipstr{k})
end

plotEditBtn = uigettool(f,'Standard.EditPlot');
set(plotEditBtn,'ClickedCallback',{@localPlotEditClicked newView});

%% HG Toolbar buttons de-activate custom toolbar
hgbuttons = [uigettool(f,'Exploration.ZoomIn');...
             uigettool(f,'Exploration.ZoomOut');...
             uigettool(f,'Exploration.Pan');...
             uigettool(f,'Standard.EditPlot')];
set(hgbuttons,'OnCallback',{@localCustomTBoff h})
   
%% Remove rotate3d toolbar button
delete(uigettool(f,'Exploration.Rotate'));

%% Customize the pan toolbar click
% set(hgbuttons(3),'clickedcallback',@(es,ed) tspantool(get(h,'Plot'),es));

%% Expand and select the new view node
manager.Tree.expand(this.getTreeNodeInterface);
manager.Tree.expand(newView.getTreeNodeInterface);


%% Listener to timeseries being removed
newView.addlisteners(handle.listener(this.getRoot,'tsstructurechange',...
    {@localRemoveTs newView}));

set(manager.figure,'Pointer','arrow')



function cdata = localGetIcon(thispath)

%% Get the icon for the data selection toolbar button
[cdata,map] = imread(thispath);

% Set all white (1,1,1) colors to be transparent (nan)
ind = find(map(:,1)+map(:,2)+map(:,3)==3);
map(ind) = nan; %#ok<FNDSB>
cdata = ind2rgb(cdata,map);

function localSetSelectmode(eventSrc,eventData,h,type) %#ok<INUSL,INUSL>

% onCallback to select mode toolbar button which sets the select mode
% of the view

% Check that the Plot had been created
if ~isempty(h.Plot) && ishandle(h.Plot)
   h.Plot.setselectmode(type);
end

function localClearSelectmode(eventSrc,eventData,h) %#ok<INUSL,INUSL>

% offCallback to select mode toolbar button which sets the select mode
% of the view to None

if all(strcmp(get(h.Handles.ToolbarBtns,'State'),'off'))
    % Check that the Plot had been created and is not locked
    if ~isempty(h.Plot) && ishandle(h.Plot)
       h.Plot.setselectmode('None');
    end
end

    
function localRemoveTs(eventSrc,eventData,view) %#ok<INUSL>

%% Listener callback for @tsnodes being removed which removes the
%% corresponding waveform from any listening views
if ~isempty(view.Plot) && ishandle(view.Plot) && strcmp(eventData.Action,'remove')
    tsList = eventData.Node.getTimeSeries;
    for k=1:length(tsList)
        view.removets(tsList{k});
    end
end


function localCustomTBoff(es,ed,h) %#ok<INUSL,INUSL>

%% HG Toolbarbutton OnCallback which clears special selection modes and
%% unpops their toolbar buttons
if ~isempty(h.Plot) && ishandle(h.Plot) && ~strcmpi(h.Plot.State,'None')
    h.Plot.setselectmode('None')
end


function deletemenubyname (f, name)

m = findall (f, 'type', 'uimenu', 'label', name);
if ~isempty(m)
    delete(m);
end

function deletemenubytag (f, name)

m = findall (f, 'type', 'uimenu', 'Tag', name);
if ~isempty(m)
    delete(m);
end

function localPlotEditClicked(es,ed,h) %#ok<INUSL>

%% Overridden callback to prevent the property editor from reverting to the
%% figure when going out of plot edit mode
if isempty(h.Plot) || ~ishandle(h.Plot)
    return
end
state = get(es,'state');
% If going out of plot edit mode, clear object selection. This is needed to
% prevent the property editor combining previous selections with new ones
% with the result that the property editor will go into "multiple object"
% form rather than reflecting the uitspanel.
if strcmp(state,'off')
    g = getselectobjects(ancestor(h.Plot.AxesGrid.Parent.Parent,'figure'));
    if ~isempty(g)
        selectobject(g,'off')
    end
end
plotedit(h.Plot.AxesGrid.Parent,state);
