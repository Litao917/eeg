function dataEdit(es,~,action,newvalue)
% This undocumented function may be removed in a future release.

% Copyright 2007-2013 The MathWorks, Inc.

% Function for replacing data in linked and unlinked graphics in linked and
% unlinked plots. Allows combined undo and redo operations when acting on
% multiple objects/variables. Functionality has been combined into a single
% function to avoid code duplication.

fig = ancestor(es,'figure');

if ~graphicsversion(fig,'handlegraphics')
    if nargin<=3
        datamanager.dataEditUsingMATLABClasses(es,[],es,action);
    else
        datamanager.dataEditUsingMATLABClasses(es,[],es,action,newvalue);
    end
    return
end

% Get the current parent object: axes if invoked from a context menu,
% otherwise figure 
gContainer = fig;
if ~isempty(es) && ~isempty(ancestor(es,'uicontextmenu')) 
    gContainer = get(fig,'CurrentAxes');
    if isempty(gContainer)
        gContainer = fig;
    end
end

% Find replacement value/keep flag if none specified
if strcmp(action,'replace')
    if nargin==3
        newvalue = datamanager.replacedlg;
        if isempty(newvalue)
            return
        end
    end
    if isnan(newvalue)
        actionStr = getString(message('MATLAB:datamanager:dataEdit:ReplaceWithNaNs'));
    else
        actionStr = getString(message('MATLAB:datamanager:dataEdit:ReplaceWithAConstant'));
    end
elseif strcmp(action,'remove')
    if nargin==3 || ~newvalue
        actionStr = getString(message('MATLAB:datamanager:dataEdit:RemovePoints'));
        newvalue = false;
    else
        actionStr = getString(message('MATLAB:datamanager:dataEdit:RemoveUnbrushedPoints'));
    end
end

% Find brushed graphics
sibs = datamanager.getAllBrushedObjects(gContainer);
fig = ancestor(gContainer,'figure');
if isempty(sibs)
    errordlg(getString(message('MATLAB:datamanager:dataEdit:AtLeastOneGraphicObjectMustBeBrushed')),'MATLAB','modal')
    return
end

% Build a list of effected items:
%  - Struct array varItems: representing linked variable data sources in 
%    linked plots
%  - Struct array graphicItems: representing graphics handles of unlinked
%    plots and graphics without data sources in linked plots
graphicItems = {};
varItems = repmat(struct('VarName','','VarValue',[],'BrushingArray',[]),[0 1]);
if datamanager.isFigureLinked(fig)
     h = datamanager.linkplotmanager;
     brushMgr = datamanager.brushmanager;
     [mfile,fcnname] = datamanager.getWorkspace(1);    
     for k=1:length(sibs)
         linkedVars = h.getLinkedVarsFromGraphic(sibs(k),mfile,fcnname);
         % Linked graphic, create variable struct
         if ~isempty(linkedVars) 
             for j=1:length(linkedVars)
                 varValue = evalin('caller',[linkedVars{j} ';']);
                 varStruct = struct('VarName',linkedVars{j},...
                        'VarValue',varValue,'BrushingArray',...
                        brushMgr.getBrushingProp(linkedVars{j},mfile,fcnname,'I'));              
                 varItems = [varItems;varStruct]; %#ok<AGROW>
             end
         end 
         
         % Is there unlinked manual data
         if isempty(hggetbehavior(sibs(k),'linked','-peek'))
             isUnlinkedXData = isempty(get(sibs(k),'XDataSource')) && ...
                               (~isempty(findprop(handle(sibs(k)),'XDataMode')) && ...
                                 strcmp(get(sibs(k),'XDataMode'),'manual'));         
             isUnlinkedYData = isempty(get(sibs(k),'YDataSource'));
             isUnlinkedZData = ~isempty(findprop(handle(sibs(k)),'ZData')) && ...
                               ~isempty(findprop(handle(sibs(k)),'ZDataSource')) && ...
                               ~isempty(get(sibs(k),'ZData')) && ...
                                isempty(get(sibs(k),'ZDataSource'));
         else
             isUnlinkedXData = false;
             isUnlinkedYData = false;
             isUnlinkedZData = false;
         end
         % Unlinked graphic or linked graphic with unlinked X/Y Data in manual
         % data mode => get the graphic
         if isempty(linkedVars) || isUnlinkedXData || isUnlinkedYData || ...
                 isUnlinkedZData
             gobj = getappdata(double(sibs(k)),'Brushing__');
             gStruct = gobj.serializeBrushDataStruct(sibs(k));    
             graphicItems = [graphicItems;{gStruct}]; %#ok<AGROW>
         end
     end
else
    for k=1:length(sibs)
        gobj = getappdata(double(sibs(k)),'Brushing__');
        gStruct = gobj.serializeBrushDataStruct(sibs(k));
        graphicItems = [graphicItems;{gStruct}]; %#ok<AGROW>
    end
end

 
% Obtain a list of proxy objects to protect against later deletion
% objects referenced in the undo stack (c.f. dsternbe)
if ~isempty(graphicItems)
    proxies = cellfun(@(x) x.ProxyVal,graphicItems, 'UniformOutput',false);
    proxyVal = plotedit({'getProxyValueFromHandle',[proxies{:}]});
    for k=1:length(graphicItems)
        graphicItems{k}.ProxyVal = proxyVal(k);
    end
end

% Update the figure undo stack
datamanager.updateFigUndoMenu(fig,actionStr,...
    @(fig,varItems,graphicItems,newvalue,action) localEditGraphic(fig,varItems,graphicItems,newvalue,action),...
    {fig,varItems,graphicItems,newvalue,action},...
    @(fig,varItems,graphicItems) localEditGraphicInv(fig,varItems,graphicItems),...
    {fig,varItems,graphicItems});

% Do it
localEditGraphic(fig,varItems,graphicItems,newvalue,action);


% Package replace as a local function for redo operations
function localEditGraphic(fig,varItems,graphicItems,newvalue,action)

% Deal with unlinked graphics or graphics with manually specified data
if ~isempty(graphicItems)
    % Obtain the handles from the proxy objects
    objArrayProxies = cellfun(@(x) x.ProxyVal,graphicItems,'UniformOutput',false);
    if ~all(ishandle(objArrayProxies))
        objArray = plotedit({'getHandleFromProxyValue',fig,[objArrayProxies{:}]});
    else
        objArray = objArrayProxies;
    end

    for k=length(objArray):-1:1
        loc_brushObj = getappdata(double(objArray(k)),'Brushing__');
        % If a brushed graphic object was deleted after the undo action was
        % created, the brushing object (stored in the appdata) will have been
        % deleted. In this situation recreate a fresh one.
        if isempty(loc_brushObj) || ~ishandle(loc_brushObj)
           brushObj(k) = datamanager.enableBrushing(objArray(k));
        else
           brushObj(k) = loc_brushObj;
        end
        
        % Turn off SelectionListeners so that incomplete groups of area
        % peers do not attempt to redraw before all removes have been
        % processed.
        if isa(brushObj(k).SelectionListener, 'handle.listener')
            set(brushObj(k).SelectionListener,'Enable','off');
        else
            brushObj(k).SelectionListener.Enabled = false;
        end
        brushObj(k).combinePeerBrushingArrays;
    end
    for k=1:length(brushObj)
        if strcmp(action,'replace')
            brushObj(k).replace(newvalue);
        elseif strcmp(action,'remove')
            brushObj(k).remove(newvalue);
        end
    end
    
    for k=1:length(brushObj)
        brushObj(k).draw;
        if isa(brushObj(k).SelectionListener, 'handle.listener')
            set(brushObj(k).SelectionListener,'Enable','on');
        else
            brushObj(k).SelectionListener.Enabled = true; %#ok<AGROW>
        end
    end
end

% Deal with variables from linked graphics
if ~isempty(varItems)
    cmd = 'datamanager.dataEditCallback({';
    for k=1:length(varItems)-1
        cmd = [cmd,'''' varItems(k).VarName ''',']; %#ok<AGROW>
    end 
    cmd = [cmd,'''' varItems(end).VarName '''},''action'',''' action ''',''arguments'',{' num2str(newvalue,12) '});'];
    h = datamanager.linkplotmanager;
    h.LinkListener.executeFromDataSource(cmd,fig);
end

% Package inverse of replace as a local function handle for undo operations
function localEditGraphicInv(fig,varItems,graphicItems)

% Deal with unlinked graphics
if ~isempty(graphicItems)
    % Obtain the handles from the proxy objects
    objArrayProxies = cellfun(@(x) x.ProxyVal,graphicItems,'UniformOutput',false);
    if ~all(ishandle(objArrayProxies))
        objArray = plotedit({'getHandleFromProxyValue',fig,[objArrayProxies{:}]});
    else
        objArray = [objArrayProxies{:}];
    end

    
    for k=1:length(graphicItems)
        brushObj = getappdata(double(objArray(k)),'Brushing__');
        for j=1:length(brushObj)
            localDeserializeBrushDataStruct(graphicItems{k},objArray(k))
        end
    end
    for k=1:length(objArray)
        bobj = getappdata(double(objArray(k)),'Brushing__');
        if ~isempty(bobj) && ishandle(bobj)
            bobj.combinePeerBrushingArrays;
        else % Recovering from container deletion
            datamanager.enableBrushing(objArray(k));
        end
    end
    for k=1:length(objArray)
        set(objArray(k),'BrushData',graphicItems{k}.BrushingArray);
    end
end

% Deal with variables from linked graphics
if ~isempty(varItems)
    h = datamanager.brushmanager;
    for k=1:length(varItems)
        h.UndoData.(strrep(varItems(k).VarName,'.','_')) = varItems(k).VarValue;
        h.UndoData.Brushing.(strrep(varItems(k).VarName,'.','_')) = varItems(k).BrushingArray;
    end
    cmd = 'datamanager.dataEditCallback({';
    for k=1:length(varItems)-1
        cmd = [cmd,'''' varItems(k).VarName ''',']; %#ok<AGROW>
    end 
    cmd = [cmd,'''' varItems(end).VarName '''},''action'',''undo'');'];
    h = datamanager.linkplotmanager;
    h.LinkListener.executeFromDataSource(cmd,fig);
end 

function localDeserializeBrushDataStruct(brushDataStruct,gObj)

% Special treatment for scatter
extraPVPairs = {};
if isa(gObj,'specgraph.scattergroup')
    % Deserialize non-scalar SizeData
    
    if length(brushDataStruct.Sizedata)>1
        extraPVPairs = [extraPVPairs {'SizeData' brushDataStruct.Sizedata}];
    end
    
    % Serialize vector valued CData
    if size(brushDataStruct.Cdata,1)>1
        extraPVPairs = [extraPVPairs {'CData' brushDataStruct.Cdata}];
    end
end

% Serialize XData,YData and ZData
datamanager.deserializeBrushDataStruct(brushDataStruct,gObj,extraPVPairs);

 