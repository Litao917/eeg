function addContextMenu(this)

% Copyright 2008-2011 The MathWorks, Inc.

% Create and add a context menu to the supplied graphic object. Updates
% the corresponding datamanager object

if ~isempty(this.ContextMenu) && ishandle(this.ContextMenu)
    if any(cellfun('isempty',get(this.SelectionHandles,{'uicontextmenu'})))
        set(this.SelectionHandles,'uicontextmenu',this.ContextMenu);
    end
    return
end

fig = ancestor(this.HGHandle,'figure');
cmenu = getappdata(fig,'BrushingContextMenu');
if isempty(cmenu) || ~ishandle(cmenu)
    cmenu = uicontextmenu('Parent',fig,'Serializable','off','Tag',...
        'BrushSeriesContextMenu');
    setappdata(fig,'BrushingContextMenu',cmenu);
    mreplace = uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuReplaceWith')),'Tag','BrushSeriesContextMenuReplaceWith');
    uimenu(mreplace,'Label',getString(message('MATLAB:datamanager:brushobj:MenuNaNs')),'Tag','BrushSeriesContextMenuNaNs','Callback',{@datamanager.dataEdit 'replace' NaN});
    uimenu(mreplace,'Label',getString(message('MATLAB:datamanager:brushobj:MenuDefineAConstant')),'Tag','BrushSeriesContextMenuDefineAConstant','Callback',...
      {@datamanager.dataEdit 'replace'});
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuRemove')),'Tag','BrushSeriesContextMenuRemove','Callback',{@datamanager.dataEdit 'remove' false});
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuRemoveUnbrushed')),'Tag','BrushSeriesContextMenuRemoveUnbrushed','Callback',...
      {@datamanager.dataEdit 'remove' true});
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuCreateVariable')),'Tag','BrushSeriesContextMenuCreateVariable','Callback',...
      {@datamanager.newvar},'Separator','on');
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuPasteDataToCommandLine')),'Tag','BrushSeriesContextMenuPasteDataToCommandLine','Callback',...
      {@datamanager.paste},'Tag','LiveLine','Separator','on');
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuCopyDataToClipboard')),'Tag','BrushSeriesContextMenuCopyDataToClipboard','Callback',...
      {@datamanager.copySelection});
    uimenu(cmenu,'Label',getString(message('MATLAB:datamanager:brushobj:MenuClearAllBrushing')),'Tag','BrushSeriesContextMenuClearAllBrushing','Callback',...
      @localClearBrushing,'Separator','on');
end

this.ContextMenu = cmenu;
for k=1:length(this.SelectionHandles)
     set(this.SelectionHandles(k),'uicontextmenu',cmenu);
end

function localClearBrushing(es,~)

fig =  ancestor(es,'figure');
ax = get(fig,'CurrentAxes');
brushMgr = datamanager.brushmanager;
if isprop(handle(fig),'LinkPlot') && get(fig,'LinkPlot')    
    [mfile,fcnname] = datamanager.getWorkspace(1);
    brushMgr.clearLinked(fig,ax,mfile,fcnname);
end
brushMgr.clearUnlinked(ax);

