function h = tsImportdlg(varargin)

% Copyright 2004-2012 The MathWorks, Inc.

import javax.swing.*;
import com.mathworks.mwswing.*;
import java.awt.*;

h = tsguis.tsImportdlg;
h.OutputValue = [];
for k=1:floor(nargin/2)
    set(h,varargin{2*k-1},varargin{2*k});
end

%% Build HG components
% figure window
heightbtn=23;
widthbtn=80;
separation=10;
leftratio=0.25;
bottomratio=0.3;
widthratio=0.5;
heightratio=0.4;
ScreenSize=get(0,'ScreenSize');
h.Figure=figure('Name', h.Title, ...
        'WindowStyle','modal', ...
        'HandleVisibility', 'Callback', ...
        'Units', 'pixels', ...
        'Toolbar', 'None', ...
        'Menubar', 'None', ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible','off', ...
        'Position',[ScreenSize(3)*leftratio ...
                    ScreenSize(4)*bottomratio ...
                    ScreenSize(3)*widthratio ...
                    ScreenSize(4)*heightratio], ...
        'CloseRequestFcn', {@localFigClose h},...
        'Tag','tsImportDlg',...
        'IntegerHandle','off');
% buttons
h.Handles.BTNrefresh = uicontrol('Parent', h.Figure, 'Position',[ScreenSize(3)*widthratio-4*widthbtn-4*separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback', {@localRefresh h}, 'String', ...
    getString(message('MATLAB:timeseries:tsguis:tsImportdlg:Refresh')), ...
    'Tag', 'BTNrefresh');
h.Handles.BTNselect = uicontrol('Parent', h.Figure, 'Position',[ScreenSize(3)*widthratio-3*widthbtn-3*separation, separation, widthbtn, heightbtn],...
     'BusyAction', 'Cancel','Interruptible','off',...
     'Style', 'pushbutton','Callback', {@localSave h}, 'String', ...
     getString(message('MATLAB:timeseries:tsguis:tsImportdlg:Import')), ...
     'Tag', 'BTNselect');
h.Handles.BTNcancel = uicontrol('Parent',h.Figure,'Position',[ScreenSize(3)*widthratio-2*widthbtn-2*separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback', {@localCancel h},  'String', ...
    getString(message('MATLAB:timeseries:tsguis:tsImportdlg:Cancel')), ...
    'Tag', 'BTNcancel');
h.Handles.BTNhelp = uicontrol('Parent',h.Figure,'Position',[ScreenSize(3)*widthratio-widthbtn-separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback',{@localDispatchhelp h},... 
    'String', ...
    getString(message('MATLAB:timeseries:tsguis:tsImportdlg:Help')), ...
    'Tag', 'BTNhelp');
% workspace browser
h.Handles.Browser = tsguis.tsvarbrowser;
h.Handles.Browser.typesallowed = h.TypesAllowed;
h.Handles.Browser.open;
h.Handles.Browser.javahandle.setName('tsImportdlgImportView');
[~, h.Handles.jBrowser] = javacomponent(h.Handles.Browser.javahandle.getScrollContainer,...
    [separation, 40, ScreenSize(3)*widthratio-2*separation, ...
    ScreenSize(4)*heightratio-40-separation],h.Figure);

% Install default listeners
h.Listeners = handle.listener(h,h.findprop('Visible'),'PropertyPostSet',...
      {@localSetVisible h});


function localRefresh(~,~, h)

% callback for refresh button
h.Handles.Browser.open;
awtinvoke(h.Handles.Browser.javahandle,'clearSelection()')


function localFigClose(~,~, h)

h.OutputValue = [];
uiresume(h.Figure);
delete(h.Figure);

function localSave(~,~, h)

% To avoid uitree (java part) object populating process to be blocked by the
% second import dialog, in the save action, we check if the tree is still
% busy, if so, then issue a message and quit.
v = tsguis.tsviewer;
if ~isempty(v.TreeManager.Tree.getTree.getSelectionModel.fCurrentPath)
    uiwait(msgbox(getString(message('MATLAB:timeseries:tsguis:tsImportdlg:CannotImport')),...
        getString(message('MATLAB:timeseries:tsguis:tsImportdlg:ImportFromWorkspace')),'modal'));
    localFigClose([], [], h)
    return
end

% Import selected variables, one at a time 
selectedRows=h.Handles.Browser.javahandle.getSelectedRows;
if isempty(selectedRows)
    msgbox(getString(message('MATLAB:timeseries:tsguis:tsImportdlg:SelectOneOrMoreItemsToImport')), ...
        getString(message('MATLAB:timeseries:tsguis:tsImportdlg:ImportFromWorkspace')));

    return
end
for i=1:length(selectedRows)
    thisrow = h.Handles.Browser.javahandle.convertRowIndexToUnderlyingModel(selectedRows(i))+1; 
    name = h.Handles.Browser.Variables(thisrow).varname;
    if ~isempty(name)
        tmp = evalin('base',[name ';']);
        if isa(tmp,'timeseries')
            h.OutputValue.(name) = tsdata.timeseries(tmp);
        else
            h.OutputValue.(name) = tmp;
        end  
        if strcmp(h.OutputValue.(name).name,'unnamed') && ~strcmp(name,'unnamed')
            h.OutputValue.(name).name = name;
        end
        % Check if events are duplicated
        if isa(h.OutputValue.(name),'tsdata.timeseries')
            len = length(get(h.OutputValue.(name),'Events'));
            if len>0
                for j=1:len
                    str(j) = {h.OutputValue.(name).events(j).name}; %#ok<AGROW>
                end
                if length(unique(str))~=len
                    h.OutputValue = rmfield(h.OutputValue,name);
                    errordlg(getString(message('MATLAB:timeseries:tsguis:tsImportdlg:UnableToLoadObject',name)),...
                        getString(message('MATLAB:timeseries:tsguis:tsImportdlg:TimeSeriesTools')),'modal');
                end
            end
        end
    end
end

%% Close the importer in a way which minimizes the appearance of a ghost
%% image of its window in the tstool (g252886)
set(h.Figure,'Visible','off')
drawnow
uiresume(h.Figure);
delete(h.Figure);
figure(v.TreeManager.Figure);
drawnow

function localCancel(~,~, h)

h.OutputValue = [];
uiresume(h.Figure);
delete(h.Figure);

function localDispatchhelp(~,~,h)

tsDispatchHelp(h.HelpFile,'modal',h.Figure)

function localSetVisible(~,~,h)

set(get(h,'Figure'),'Visible',get(h,'Visible'))