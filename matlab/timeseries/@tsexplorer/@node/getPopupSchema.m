function menu = getPopupSchema(this, manager)
% GETPOPUPSCHEMA Constructs the default popup menu


%  Copyright 1986-2011 The MathWorks, Inc.

menu  = com.mathworks.mwswing.MJPopupMenu;
Item1 = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:tsexplorer:node:getPopupSchema:Add')));
Item2 = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:tsexplorer:node:getPopupSchema:Delete')));
Item3 = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:tsexplorer:node:getPopupSchema:Rename')));

menu.add( Item1 );
menu.add( Item2 );
menu.add( Item3 );

this.Handles.MenuItems = [ Item1; Item2; Item3 ];
set( Item1, 'ActionPerformedCallback', {@LocalAdd, this, manager} );
set( Item1, 'MouseClickedCallback',    {@LocalAdd, this, manager} );

set( Item2, 'ActionPerformedCallback', {@LocalDelete, this, manager} );
set( Item2, 'MouseClickedCallback',    {@LocalDelete, this, manager} );

set( Item3, 'ActionPerformedCallback', {@LocalRename, this, manager} );
set( Item3, 'MouseClickedCallback',    {@LocalRename, this, manager} );

% --------------------------------------------------------------------------- %
function LocalAdd(~, ~, this, ~)
this.addNode;

% --------------------------------------------------------------------------- %
function LocalDelete(~, ~, this, manager)
if ~isempty(this.getRoot)
    manager.reset
    manager.Tree.setSelectedNode(this.getRoot.getTreeNodeInterface)
    drawnow % Force the node to show seelcted
    manager.Tree.repaint
    this.up.removeNode(this);
end
% --------------------------------------------------------------------------- %
function LocalRename(~, ~, this, ~)

newname = inputdlg(getString(message('MATLAB:tsexplorer:node:getPopupSchema:NewNodeName')), ...
    getString(message('MATLAB:tsexplorer:node:getPopupSchema:TimeSeriesTools')));
if ~isempty(newname)
    set(this.treenode,'Name',newname{1});
end
% manager.tree.getTree.startEditingAtPath(manager.tree.getTree.getSelectionPath)

% Tree = manager.ExplorerPanel.getSelector.getTree;
% Tree.startEditingAtPath(Tree.getSelectionPath);


