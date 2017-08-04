function menu = getDefaultPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 1986-2012 The MathWorks, Inc.

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuDelete = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:viewnode:Delete')));
menuCopy = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:viewnode:Copy')));
menuPaste = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:viewnode:Paste')));
menuRename = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:viewnode:Rename')));

%% Add them
menu.add(menuCopy);
menu.add(menuPaste);
menu.addSeparator;
menu.add(menuDelete);
menu.add(menuRename);

%% Assign menu callbacks
set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
    {@localRemove this,manager});
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    {@localCopy this,manager})
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    {@localPaste this,manager})
set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalRename,this});

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

% --------------------------------------------------------------------------- %
function LocalRename(~,~,this)

name = inputdlg(...
    getString(message('MATLAB:timeseries:tsguis:viewnode:NewNodeName')),...
    getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesTools')),...
    1,{this.Label});
if ~isempty(name)
    %Check duplicate or empty names
    [newname, status] = chkNameDuplication(this.up,name{1},class(this));
    if ~status
        return;
    end
   this.Label = newname;
end

function localSetPasteMenu(~,~,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.viewnode'));

function localRemove(~,~,h,manager)

remove(h,manager);

function localCopy(~,~,h,manager)

copynode(h,manager)

function localPaste(~,~,h,manager)

pastenode(h,manager)
