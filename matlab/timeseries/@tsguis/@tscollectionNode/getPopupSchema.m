function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu for tscollection node

% Author(s): Rajiv Singh
% Copyright 2005-2012 The MathWorks, Inc.

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuDelete = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Remove')));
menuCopy = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Copy')));
menuPaste = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Paste')));
menuRename = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Rename')));
menuRemoveMissing = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:RemoveMissingData')));
menuDetrend = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Detrend')));
menuFilter = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Filter')));
menuInterpolate = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Interpolate')));
menuExport = com.mathworks.mwswing.MJMenu(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Export')));
menuExportFile = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:ToFile')));
menuExportWorkspace = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:ToWorkspace')));
menuExpression = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TransformAlgebraically')));
menuAddTs = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:AddTimeSeries')));

%% Add them
menu.add(menuAddTs);
menu.addSeparator;
menu.add(menuCopy);
menu.add(menuPaste);
menu.addSeparator;
menu.add(menuDelete);
menu.add(menuRename);
menu.addSeparator;
menu.add(menuExport);
menuExport.add(menuExportFile);
menuExport.add(menuExportWorkspace);
menu.addSeparator;
menu.add(menuRemoveMissing);
menu.add(menuDetrend);
menu.add(menuFilter);
menu.add(menuInterpolate);
menu.addSeparator;
menu.add(menuExpression);

%% Assign menu callbacks
set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
    {@localRemove this manager})
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    {@localCopy this manager})
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    {@localPaste this manager})
set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalRename,this}); 
set(handle(menuExportFile,'callbackproperties'),'ActionPerformedCallback',...
    {@localOpenExportdlg this manager})  
set(handle(menuExportWorkspace,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalExportWorkspace,this});
set(handle(menuRemoveMissing,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 4})
set(handle(menuDetrend,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 1})
set(handle(menuFilter,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 2})
set(handle(menuInterpolate,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 3})
set(handle(menuExpression,'callbackproperties'),'ActionPerformedCallback',...
     {@localOpenarithdlg this manager});

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

this.Handles.MenuItems = menuAddTs;
set(handle(menuAddTs,'CallbackProperties'), 'ActionPerformedCallback', ...
    {@localAddNewMember,this});
               

% ---------------------------------------------------------------------- %
function LocalRename(~,~,this)

name = inputdlg(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:NewNodeName')), ...
        getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeSeriesTools')));
if ~isempty(name)
    %Check duplicate or empty names
    [newname, status] = chkNameDuplication(this.up,name{1},class(this));
    if ~status
        return;
    end
    
    
    % Check that this timeseries is not plotted
    viewerH = tsguis.tsviewer;
    if viewerH.isTimeseriesViewed(this)
        errordlg(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:CannotChangeName')),...
            getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeSeriesTools')), ...
            'modal')
        return
    end
    
    this.Tscollection.Name = newname;
end

%--------------------------------------------------------------------------
function localSetPasteMenu(~,~,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.tscollectionNode') ||...
    isa(viewer.ClipBoard,'tsguis.tsnode'));

%--------------------------------------------------------------------------
function LocalExportWorkspace(~,~,this)

%% Export this tscollection object to workspace
list = evalin('base','whos;');
flag = false; % Is the new var name already in the workspace
newName = genvarname(this.Tscollection.name);
for i=1:length(list)
    if strcmp(list(i).name,newName)
        flag = true;
        break;
    end
end
if ~strcmp(this.Tscollection.name,newName)
        warning(message('MATLAB:tsgtscNodegetPopupSchema:InvalidObjectName', newName));
end

%% Write the tscollection to the workspace, perhaps after warning
%% about an overwrite
if flag
    ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:VariableNameExists', newName)),...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:DuplicateVariableDetected')), ...  
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Overwrite')), ...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Abort')), ...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Overwrite')));
    switch ButtonName,
        case getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Overwrite'))
            assignin('base',newName,this.Tscollection.TsValue);
        case getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Abort'))
            return
    end
else
    assignin('base',newName,this.Tscollection.TsValue);
end

msgbox(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:ObjectWasExported', this.Tscollection.Name)), ...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeSeriesTools')),'modal');

%--------------------------------------------------------------------------
function localAddNewMember(~,~,this)

importTsCallback(this);

%--------------------------------------------------------------------------
function localPreproc(~,~,this,Ind)


RS = tsguis.datapreprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);

function localRemove(~,~,h,manager)

remove(h,manager);

function localCopy(~,~,h,manager)

copynode(h,manager);

function localPaste(~,~,h,manager)

pastenode(h,manager);

function localOpenExportdlg(~,~,h,manager)

openExportdlg(h,manager);

function localOpenarithdlg(~,~,h,manager)

openarithdlg(h,manager,get(h,'Label'))