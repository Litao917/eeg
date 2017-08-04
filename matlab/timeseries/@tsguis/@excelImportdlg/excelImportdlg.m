function this = excelImportdlg(parent)
% EXCELIMPORTDLG is the constructor of the class, which imports time series
% from an excel workbook into tstool

% Author: Rong Chen 
% Revised: 
% Copyright 2005-2012 The MathWorks, Inc.

% -------------------------------------------------------------------------
% create a singleton of this import dialog
% -------------------------------------------------------------------------
this = tsguis.excelImportdlg; 
this.Parent = parent;

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
this.defaultPositions;

% -------------------------------------------------------------------------
% initiaize figure window
% -------------------------------------------------------------------------
% create the main figure window
this.Figure = this.Parent.Figure;

% -------------------------------------------------------------------------
% get default background colors for all components
% -------------------------------------------------------------------------
this.DefaultPos.FigureDefaultColor=get(this.Figure,'Color');
this.DefaultPos.EditDefaultColor=[1 1 1];

% -------------------------------------------------------------------------
% if WINDOWS PC OS, get a list of activex server.  if an excel comserver
% exists, try to establish a webcomponent connection as well as initialize
% the activex cotnrol to display, otherwise use uitable for display
% -------------------------------------------------------------------------
% excel comserver connection to the original source
% this.Handles.WebComponent=[];    
% excel activex control to display
this.Handles.ActiveX=[];
% uitable to display
this.Handles.tsTable=[];

% -------------------------------------------------------------------------
% other initialization
% -------------------------------------------------------------------------
this.IOData.FileName='';
this.IOData.SelectedRows=[];
this.IOData.SelectedColumns=[];
this.IOData.checkLimit=20;

this.DeleteListener = handle.listener(this,'ObjectBeingDestroyed',@localDelete);

function localDelete(this,~)

if ~isempty(this.Handles.tsTable) && ishandle(this.Handles.tsTable)
     set(handle(this.Handles.tsTable.getTable.getSelectionModel,'callbackproperties'),'ValueChangedCallback',[]);
     set(handle(this.Handles.tsTable.getTable.getColumnModel.getSelectionModel,'callbackproperties'),'ValueChangedCallback',[]);
     this.Handles.tsTable.cleanup;
end
if ~isempty(this.Figure) && ishandle(this.Figure)
    delete(this.Figure)
end


