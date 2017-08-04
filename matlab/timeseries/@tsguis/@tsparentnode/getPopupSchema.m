function menu = getPopupSchema(this,manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 2005-2012 The MathWorks, Inc.

%% Add the Add time series menu
menu  = com.mathworks.mwswing.MJPopupMenu;
menuAddTs = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:ImportWorkspaceObjects')));
menuImportRawData = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:ImportRawData')));
menuPaste = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:Paste')));
menu.add(menuAddTs);
menu.add(menuImportRawData);
menu.add(menuPaste);

this.Handles.MenuItems = [menuAddTs;menuPaste;menuImportRawData];
set(handle(menuAddTs,'CallbackProperties'), 'ActionPerformedCallback', ...
    {@localAddNode this});
set(handle(menuImportRawData,'CallbackProperties'), 'ActionPerformedCallback', ...
    @localImport);
set(handle(menuPaste,'CallbackProperties'), 'ActionPerformedCallback', ...
    {@localPaste this manager});

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

function localSetPasteMenu(~,~,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.tsnode') || ...
    isa(viewer.ClipBoard,'tsguis.tscollectionNode'));

function localAddNode(~,~,h)

addNode(h);

function localImport(~,~)

tsguis.ImportWizard(tsguis.tsviewer)

function localPaste(~,~,h,manager)

paste(h,manager);


