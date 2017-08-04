function open(h,varargin)
% Configures and opens tstool with the Timeseries data and View nodes.

%   Copyright 2004-2013 The MathWorks, Inc.

mlock 

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;
import javax.swing.tree.*;

% Wait bar for monitoring
if nargin==1
    wb = waitbar(0,getString(message('MATLAB:timeseries:tsguis:tsviewer:InitializingTimeSeriesTools')),...
        'Name',getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')));
else
    wb = varargin{1};
end

try
    if ishandle(wb)
       waitbar(.05,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:InitializingClasses')));
    end
    % Clean up any invalid objects
    if ~isempty(h.TreeManager) && ishandle(h.TreeManager)
        delete(h.TreeManager)      
    end
    h.TreeManager = [];
    if ishandle(wb)
       waitbar(.1,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:BuildingGraphics')));
    end
    % Build the tree
    rootNode = tsexplorer.Workspace(getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesSession')));
    rootNode.TsViewer = h;
    timeseriesNode = tsguis.tsparentnode(getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeries')));
    rootNode.addNode(timeseriesNode);

    if ishandle(wb)
       waitbar(.2,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:CreatingNodes')));
    end
    % View nodes
    viewsNode = tsexplorer.node(getString(message('MATLAB:timeseries:tsguis:tsviewer:Views')));
    viewsNode.Tag = 'views';
    rootNode.addNode(viewsNode);
    timeViewsNode = tsguis.viewcontainer(getString(message('MATLAB:timeseries:tsguis:viewcontainer:TimePlots')),'tsguis.tsseriesview');
    timeViewsNode.Tag = 'timeplots';
    viewsNode.addNode(timeViewsNode);
    specViewsNode = tsguis.viewcontainer(getString(message('MATLAB:timeseries:tsguis:viewcontainer:SpectralPlots')),'tsguis.tsspecnode');
    specViewsNode.Tag = 'specplots';
    viewsNode.addNode(specViewsNode);
    xyViewsNode = tsguis.viewcontainer(getString(message('MATLAB:timeseries:tsguis:viewcontainer:XYPlots')),'tsguis.tsxynode');
    xyViewsNode.Tag = 'xyplots';
    viewsNode.addNode(xyViewsNode);
    corrViewsNode = tsguis.viewcontainer(getString(message('MATLAB:timeseries:tsguis:viewcontainer:Correlations')),'tsguis.tscorrnode');
    corrViewsNode.Tag = 'corrplots';
    viewsNode.addNode(corrViewsNode);
    histViewsNode = tsguis.viewcontainer(getString(message('MATLAB:timeseries:tsguis:viewcontainer:Histograms')),'tsguis.tshistnode');
    histViewsNode.tag = 'histplots';
    viewsNode.addNode(histViewsNode);
    tsexplorer.node('Macros');
    if ishandle(wb)
       waitbar(.4,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:SettingUpTheMainFigure')));
    end
    % Create a figure with an inspector panel and tree widget.
    thisFigure = figure('NumberTitle', 'off', 'Name', getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')),...
        'Units','Characters','Menubar','none','WindowStyle','normal',...
        'HandleVisibility','off','Visible','off','KeyPressFcn',...
        {@localRedoUndo h},'DockControls','off','IntegerHandle','off','Tag',...
        'tstool');
    h.TreeManager = tsexplorer.TreeManager(rootNode,'Figure',thisFigure,'DialogPosition',...
        30,'HelpDialogPosition',30);
    screenSizeinChars = hgconvertunits(thisFigure,get(0,'screenSize'),...
                                 'Pixels','Characters',thisFigure);
    posW = screenSizeinChars(3)*0.72;    
    posW = max(posW,h.TreeManager.DialogPosition+strcmp(h.TreeManager.HelpShowing,'on')*...
            h.TreeManager.HelpDialogPosition-1 + h.TreeManager.Minwidth);        
    posH = max(screenSizeinChars(4).*0.64,h.TreeManager.Minheight);
    set(thisFigure,'Position',[0 0 posW posH]);
    centerfig(thisFigure);
    % Add the motion detector to show the resize arrow for mouse
    set(thisFigure,'WindowButtonMotionFcn',{@tshoverfig h.TreeManager});
    
    % Store the last warning thrown
    [ lastWarnMsg, lastWarnId ] = lastwarn;

    % Disable the warning when using the 'JavaFrame' property
    % this is a temporary solution
    oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jf = get(thisFigure, 'JavaFrame');
    warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    % Restore the last warning thrown
    lastwarn(lastWarnMsg, lastWarnId);

    ic = fullfile(matlabroot,'toolbox/matlab/timeseries/matlabicon.gif'); %#ok<MCTBX,MCMLR>
    jf.setFigureIcon(javax.swing.ImageIcon(java.lang.String(ic)));

    % Populate the viewer with the top level node handles
    set(h,'TSNode', timeseriesNode,'ViewsNode', viewsNode);
    if ishandle(wb)
       waitbar(.6,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:InstallingMenus')));
    end
    % Install menus
    figmenus(h)
    set(thisFigure,'Userdata',h);
    if ishandle(wb)
       waitbar(.8,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:BuildingCachedFigures')));
    end
    % Set style manager
    h.StyleManager = wavepack.WaveStyleManager;

    % Open the Views node
    h.TreeManager.Tree.expand(viewsNode.getTreeNodeInterface);

    % Prevent selection of the root node
    customTreeSelectionModel  = awtcreate('com.mathworks.toolbox.timeseries.tsTreeSelectionModel',...
        '[Ljavax/swing/tree/TreePath;Lcom/mathworks/mwswing/MJTree;',...
        [TreePath(rootNode.getTreeNodeInterface);...
        TreePath([rootNode.getTreeNodeInterface;viewsNode.getTreeNodeInterface])],...
        h.TreeManager.Tree.getTree);       
    awtinvoke(h.TreeManager.Tree.getTree,'setSelectionModel(Ljavax/swing/tree/TreeSelectionModel;)',...
        customTreeSelectionModel);
    drawnow 
    
    if ishandle(wb)
       waitbar(1,wb,getString(message('MATLAB:timeseries:tsguis:tsviewer:Completed')));
    end
catch me
    errordlg(getString(message('MATLAB:timeseries:tsguis:tsviewer:ErrorOpeningTimeSeriesTools',...
       me.message)),getString(message('MATLAB:timeseries:tsguis:tsviewer:TimeSeriesTools')))
end

% If the waitbar was created in this method - close it
if nargin==1
   close(wb)
end

% Update udd from java Prefs
h.utUpdateMaxPlotLength;

function localRedoUndo(~,eventData,h)

% KeyPress callback for redo/undo
if strcmp(eventData.Key,'z') && isequal(eventData.Modifier,{'control'})
    h.undo;
elseif strcmp(eventData.Key,'y') && isequal(eventData.Modifier,{'control'})
    h.redo;
end
