function result = createFigureDefaultMenubar(fig,deploy)
% This function is undocumented and will change in a future release
%  Copyright 2009-2012 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT SMART INDENT THIS FILE!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CREATEFIGUREDEFAULTMENUBAR Create default menus.
%
%  CREATEFIGUREDEFAULTMENUBAR(F) creates the default figure menus on figure F.
%
%  If the figure handle F is not specified, 
%  CREATEFIGUREDEFAULTMENUBAR operates on the current figure(GCF).
%
%  CREATEFIGUREDEFAULTMENUBAR(F,true) creates the default menus 
%  on figure F for a deployment-only figure
%
%  If the deploy is not specified, CREATEFIGUREDEFAULTMENUBAR operates in normal mode.
%
%  H = CREATEFIGUREDEFAULTMENUBAR(...) returns the handles to the new figure children.

%  Copyright 2009-2011 The MathWorks, Inc.

hg1figure = graphicsversion(fig,'handlegraphics');

if nargin==1
    deploy = false;
end

isMenuVisible = isVisible(deploy);

% Get the menu label catalog
menuLabels = matlab.internal.Catalog('MATLAB:uistring:figuremenu');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figMenuFile = uimenu('Label',menuLabels.getString('Label_figMenuFile'),'Visible','on','Tag','figMenuFile','Callback','filemenufcn FilePost','Parent',fig,'Serializable','off','HandleVisibility','off');
    figMenuUpdateFileNew = uimenu('Label',menuLabels.getString('Label_figMenuUpdateFileNew'),'Accelerator','N','Visible',isMenuVisible,'Tag','figMenuUpdateFileNew',...
                                  'Callback','filemenufcn(gcbf,''UpdateFileNew'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuFileNewScript'),'Accelerator','N','Visible',isMenuVisible,'Tag','figMenuFileNewScript',...
                                    'Callback','filemenufcn(gcbf,''NewCodeFile'')','Parent',figMenuUpdateFileNew,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuNewFigure'),'Visible',isMenuVisible,'Tag','figMenuNewFigure',...
                                    'Callback',SHARED_NEW_CALLBACK,'Parent',figMenuUpdateFileNew,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuFileNewModel'),'Visible',isMenuVisible,'Tag','figMenuFileNewModel',...
                                    'Callback','filemenufcn(gcbf,''NewModel'')','Parent',figMenuUpdateFileNew,'Serializable','off','HandleVisibility','off');   
        uimenu('Label',menuLabels.getString('Label_figMenuFileNewVariable'),'Visible',isMenuVisible,'Tag','figMenuFileNewVariable',...
                                    'Callback','filemenufcn(gcbf,''NewVariable'')','Parent',figMenuUpdateFileNew,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuNewGUI'),'Visible',isMenuVisible,'Tag','figMenuNewGUI',...
                                    'Callback','filemenufcn(gcbf,''NewGUI'')','Parent',figMenuUpdateFileNew,'Serializable','off','HandleVisibility','off');
        
    uimenu('Label',menuLabels.getString('Label_figMenuOpen'),'Accelerator','O','Visible','on','Tag','figMenuOpen',...
                                  'Callback',SHARED_OPEN_CALLBACK,'Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFileClose'),'Accelerator','W','Visible','on','Tag','figMenuFileClose',...
                                  'Callback','filemenufcn(gcbf,''FileClose'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFileSave'),'Accelerator','S','Visible','on','Tag','figMenuFileSave',...
                                  'Callback',SHARED_SAVE_CALLBACK,'Parent',figMenuFile,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuFileSaveAs'),'Visible','on','Tag','figMenuFileSaveAs',...
                                  'Callback','filemenufcn(gcbf,''FileSaveAs'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuGenerateCode'),'Visible',isMenuVisible,'Tag','figMenuGenerateCode',...
                                  'Callback','filemenufcn(gcbf,''GenerateCode'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFileImportData'),'Visible',isMenuVisible,'Tag','figMenuFileImportData',...
                                  'Callback','filemenufcn(gcbf,''FileImportData'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuFileSaveWorkspaceAs'),'Visible',isMenuVisible,'Tag','figMenuFileSaveWorkspaceAs',...
                                  'Callback','filemenufcn(gcbf,''FileSaveWS'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFilePreferences'),'Visible',isMenuVisible,'Tag','figMenuFilePreferences',...
                                  'Callback','filemenufcn(gcbf,''FilePreferences'')','Parent',figMenuFile,'Separator','on','Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuFileExportSetup'),'Visible','on','Tag','figMenuFileExportSetup',...
                                  'Callback','filemenufcn(gcbf,''FileExportSetup'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuFilePrintPreview'),'Visible','on','Tag','figMenuFilePrintPreview',...
                                  'Callback','filemenufcn(gcbf,''FilePrintPreview'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_printMenu'),'Accelerator','P','Visible','on', 'Tag', 'printMenu', ...
                                  'Callback',SHARED_PRINT_CALLBACK,'Parent',figMenuFile,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFileExitMatlab'),'Accelerator','Q','Visible',isMenuVisible,'Tag','figMenuFileExitMatlab',...
                                  'Callback','filemenufcn(gcbf,''FileExitMatlab'')','Parent',figMenuFile,'Serializable','off','HandleVisibility','off','Separator','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              
figMenuEdit = uimenu('Label',menuLabels.getString('Label_figMenuEdit'),'Visible',isMenuVisible,'Tag','figMenuEdit','Callback','editmenufcn(gcbf,''EditPost'')','Parent',fig,'Serializable','off','HandleVisibility','off');
    
    uimenu('Label',menuLabels.getString('Label_figMenuEditUndo'),'Accelerator','Z','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditUndo','Callback','editmenufcn(gcbf,''EditUndo'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditRedo'),'Accelerator','Y','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditRedo','Callback','','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditCut'),'Accelerator','X','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditCut','Callback','editmenufcn(gcbf,''EditCut'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditCopy'),'Accelerator','C','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditCopy','Callback','editmenufcn(gcbf,''EditCopy'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditPaste'),'Accelerator','V','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditPaste','Callback','editmenufcn(gcbf,''EditPaste'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditClear'),'Enable','off','Visible',isMenuVisible,'Tag','figMenuEditClear','Callback','editmenufcn(gcbf,''EditClear'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditDelete'),'Visible',isMenuVisible,'Tag','figMenuEditDelete','Callback','editmenufcn(gcbf,''EditDelete'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditSelectAll'),'Accelerator','A','Enable','off','Visible',isMenuVisible,'Tag','figMenuEditSelectAll','Callback','editmenufcn(gcbf,''EditSelectAll'')','Parent',figMenuEdit,'Separator','on','Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditCopyFigure'),'Visible',isMenuVisible,'Tag','figMenuEditCopyFigure','Callback','editmenufcn(gcbf,''EditCopyFigure'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditCopyOptions'),'Visible',isMenuVisible,'Tag','figMenuEditCopyOptions','Callback','editmenufcn(gcbf,''EditCopyOptions'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditGCF'),'Visible',isMenuVisible,'Tag','figMenuEditGCF','Callback','editmenufcn(gcbf,''EditFigureProperties'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditGCA'),'Visible',isMenuVisible,'Tag','figMenuEditGCA','Callback','editmenufcn(gcbf,''EditAxesProperties'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditGCO'),'Visible',isMenuVisible,'Tag','figMenuEditGCO','Callback','editmenufcn(gcbf,''EditObjectProperties'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditColormap'),'Visible',isMenuVisible,'Tag','figMenuEditColormap','Callback','editmenufcn(gcbf,''EditColormap'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditFindFiles'),'Visible',isMenuVisible,'Tag','figMenuEditFindFiles','Callback','editmenufcn(gcbf,''EditFindFiles'')','Parent',figMenuEdit,'Separator','on','Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditClearFigure'),'Visible',isMenuVisible,'Tag','figMenuEditClearFigure','Callback','editmenufcn(gcbf,''EditClearFigure'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuEditClearCmdWindow'),'Visible',isMenuVisible,'Tag','figMenuEditClearCmdWindow','Callback','editmenufcn(gcbf,''EditClearCommandWindow'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditClearCmdHistory'),'Visible',isMenuVisible,'Tag','figMenuEditClearCmdHistory','Callback','editmenufcn(gcbf,''EditClearCommandHistory'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuEditClearWorkspace'),'Visible',isMenuVisible,'Tag','figMenuEditClearWorkspace','Callback','editmenufcn(gcbf,''EditClearWorkspace'')','Parent',figMenuEdit,'Serializable','off','HandleVisibility','off');

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figMenuView = uimenu('Label',menuLabels.getString('Label_figMenuView'),'Visible',isMenuVisible,'Tag','figMenuView','Callback','viewmenufcn ViewPost','Parent',fig,'Serializable','off','HandleVisibility','off');
    
    uimenu('Label',menuLabels.getString('Label_figMenuFigureToolbar'),'Visible',isMenuVisible,'Tag','figMenuFigureToolbar','Callback','viewmenufcn FigureToolbar','Parent',figMenuView,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuCameraToolbar'),'Visible',isMenuVisible,'Tag','figMenuCameraToolbar','Callback','viewmenufcn CameraToolbar','Parent',figMenuView,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuPloteditToolbar'),'Visible',isMenuVisible,'Tag','figMenuPloteditToolbar','Callback','viewmenufcn PloteditToolbar','Parent',figMenuView,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuFigurePalette'),'Visible',isMenuVisible,'Tag','figMenuFigurePalette','Callback','viewmenufcn FigurePalette','Parent',figMenuView,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuPlotBrowser'),'Visible',isMenuVisible,'Tag','figMenuPlotBrowser','Callback','viewmenufcn PlotBrowser','Parent',figMenuView,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuPropertyEditor'),'Visible',isMenuVisible,'Tag','figMenuPropertyEditor','Callback','viewmenufcn PropertyEditor','Parent',figMenuView,'Serializable','off','HandleVisibility','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Insert menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figMenuInsert = uimenu('Label',menuLabels.getString('Label_figMenuInsert'),'Visible',isMenuVisible,'Tag','figMenuInsert','Callback','insertmenufcn InsertPost','Parent',fig,'Serializable','off','HandleVisibility','off');

    uimenu('Label',menuLabels.getString('Label_figMenuInsertXLabel'),'Visible',isMenuVisible,'Tag','figMenuInsertXLabel','Callback','insertmenufcn Xlabel','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertYLabel'),'Visible',isMenuVisible,'Tag','figMenuInsertYLabel','Callback','insertmenufcn Ylabel','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertZLabel'),'Visible',isMenuVisible,'Tag','figMenuInsertZLabel','Callback','insertmenufcn Zlabel','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertTitle'),'Visible',isMenuVisible,'Tag','figMenuInsertTitle','Callback','insertmenufcn Title','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertLegend'),'Visible',isMenuVisible,'Tag','figMenuInsertLegend','Callback','insertmenufcn Legend','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertColorbar'),'Visible',isMenuVisible,'Tag','figMenuInsertColorbar','Callback','insertmenufcn Colorbar','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertLine'),'Visible',isMenuVisible,'Tag','figMenuInsertLine','Callback','insertmenufcn Line','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertArrow'),'Visible',isMenuVisible,'Tag','figMenuInsertArrow','Callback','insertmenufcn Arrow','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertTextArrow'),'Visible',isMenuVisible,'Tag','figMenuInsertTextArrow','Callback','insertmenufcn TextArrow','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertArrow2'),'Visible',isMenuVisible,'Tag','figMenuInsertArrow2','Callback','insertmenufcn DoubleArrow','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertTextbox'),'Visible',isMenuVisible,'Tag','figMenuInsertTextbox','Callback','insertmenufcn Textbox','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertRectangle'),'Visible',isMenuVisible,'Tag','figMenuInsertRectangle','Callback','insertmenufcn Rectangle','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertEllipse'),'Visible',isMenuVisible,'Tag','figMenuInsertEllipse','Callback','insertmenufcn Ellipse','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertAxes'),'Visible',isMenuVisible,'Tag','figMenuInsertAxes','Callback','insertmenufcn Axes','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuInsertLight'),'Visible',isMenuVisible,'Tag','figMenuInsertLight','Callback','insertmenufcn Light','Parent',figMenuInsert,'Serializable','off','HandleVisibility','off');

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tools menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figMenuTools = uimenu('Label',menuLabels.getString('Label_figMenuTools'),'Visible',isMenuVisible,'Tag','figMenuTools','Callback','toolsmenufcn ToolsPost','Parent',fig,'Serializable','off','HandleVisibility','off');

    uimenu('Label',menuLabels.getString('Label_figMenuToolsPlotedit'),'Visible',isMenuVisible,'Tag','figMenuToolsPlotedit','Callback','toolsmenufcn PlotEdit','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuZoomIn'),'Visible',isMenuVisible,'Tag','figMenuZoomIn','Callback','toolsmenufcn ZoomIn','Parent',figMenuTools,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuZoomOut'),'Visible',isMenuVisible,'Tag','figMenuZoomOut','Callback','toolsmenufcn ZoomOut','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuPan'),'Visible',isMenuVisible,'Tag','figMenuPan','Callback','toolsmenufcn Pan','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuRotate3D'),'Visible',isMenuVisible,'Tag','figMenuRotate3D','Callback','toolsmenufcn Rotate','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuDatatip'),'Visible',isMenuVisible,'Tag','figMenuDatatip','Callback','toolsmenufcn Datatip','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figBrush'),'Visible',isMenuVisible,'Tag','figBrush','Callback','toolsmenufcn Brush','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figLinked'),'Visible',isMenuVisible,'Tag','figLinked','Callback','toolsmenufcn Linked','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuResetView'),'Visible',isMenuVisible,'Tag','figMenuResetView','Callback','toolsmenufcn ResetView','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    figMenuOptions = uimenu('Label',menuLabels.getString('Label_figMenuOptions'),'Visible',isMenuVisible,'Tag','figMenuOptions','Callback','toolsmenufcn Options','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
        
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsXYZoom'),'Visible',isMenuVisible,'Tag','figMenuOptionsXYZoom','Callback','toolsmenufcn ZoomXY','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsXZoom'),'Visible',isMenuVisible,'Tag','figMenuOptionsXZoom','Callback','toolsmenufcn ZoomX','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsYZoom'),'Visible',isMenuVisible,'Tag','figMenuOptionsYZoom','Callback','toolsmenufcn ZoomY','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsXYPan'),'Visible',isMenuVisible,'Tag','figMenuOptionsXYPan','Callback','toolsmenufcn PanXY','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off','Separator','on');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsXPan'),'Visible',isMenuVisible,'Tag','figMenuOptionsXPan','Callback','toolsmenufcn PanX','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsYPan'),'Visible',isMenuVisible,'Tag','figMenuOptionsYPan','Callback','toolsmenufcn PanY','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsDatatip'),'Visible',isMenuVisible,'Tag','figMenuOptionsDatatip','Callback','toolsmenufcn DatatipStyle','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off','Separator','on');
        uimenu('Label',menuLabels.getString('Label_figMenuOptionsDataBar'),'Visible',isMenuVisible,'Tag','figMenuOptionsDataBar','Callback','toolsmenufcn DataBarStyle','Parent',figMenuOptions,'Serializable','off','HandleVisibility','off');
    
    uimenu('Label',menuLabels.getString('Label_figMenuEditPinning'),'Visible',isMenuVisible,'Tag','figMenuEditPinning','Callback','toolsmenufcn EditPinning','Parent',figMenuTools,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuSnapToGrid'),'Visible',isMenuVisible,'Tag','figMenuSnapToGrid','Callback','toolsmenufcn ToggleSnapToGrid','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuViewGrid'),'Visible',isMenuVisible,'Tag','figMenuViewGrid','Callback','toolsmenufcn ToggleViewGrid','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignDistributeSmart'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignDistributeSmart','Callback','toolsmenufcn AlignDistributeSmart','Parent',figMenuTools,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignDistributeTool'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignDistributeTool','Callback','toolsmenufcn AlignDistributeTool','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    figMenuToolsAlign = uimenu('Label',menuLabels.getString('Label_figMenuToolsAlign'),'Visible',isMenuVisible,'Tag','figMenuToolsAlign','Callback','toolsmenufcn InitAlign','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignLeft'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignLeft','Callback','toolsmenufcn AlignLeft','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignCenter'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignCenter','Callback','toolsmenufcn AlignCenter','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignRight'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignRight','Callback','toolsmenufcn AlignRight','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignTop'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignTop','Callback','toolsmenufcn AlignTop','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignMiddle'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignMiddle','Callback','toolsmenufcn AlignMiddle','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignBottom'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignBottom','Callback','toolsmenufcn AlignBottom','Parent',figMenuToolsAlign,'Serializable','off','HandleVisibility','off');
    
    figMenuToolsAlignDistrib = uimenu('Label',menuLabels.getString('Label_figMenuToolsAlignDistrib'),'Visible',isMenuVisible,'Tag','figMenuToolsAlignDistrib','Callback','toolsmenufcn InitAlignDistribute','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeVAdj'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeVAdj','Callback','toolsmenufcn DistributeVAdj','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeVTop'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeVTop','Callback','toolsmenufcn DistributeVTop','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeVMid'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeVMid','Callback','toolsmenufcn DistributeVMid','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeVBot'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeVBot','Callback','toolsmenufcn DistributeVBot','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeHAdj'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeHAdj','Callback','toolsmenufcn DistributeHAdj','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeHLeft'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeHLeft','Callback','toolsmenufcn DistributeHLeft','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeHCent'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeHCent','Callback','toolsmenufcn DistributeHCent','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuToolsDistributeHRight'),'Visible',isMenuVisible,'Tag','figMenuToolsDistributeHRight','Callback','toolsmenufcn DistributeHRight','Parent',figMenuToolsAlignDistrib,'Serializable','off','HandleVisibility','off');

    figDataManagerBrushTools = uimenu('Label',menuLabels.getString('Label_figDataManagerBrushTools'),'Visible',isMenuVisible,'Tag','figDataManagerBrushTools','Callback','toolsmenufcn InitBrush','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');
    
        figDataManagerBrush = uimenu('Label',menuLabels.getString('Label_figDataManagerBrush'),'Visible',isMenuVisible,'Tag','figDataManagerBrush','Callback','toolsmenufcn InitBrushReplace','Parent',figDataManagerBrushTools,'Serializable','off','HandleVisibility','off');
          
            uimenu('Label',menuLabels.getString('Label_figDataManagerReplaceNaN'),'Visible',isMenuVisible,'Tag','figDataManagerReplaceNaN','Callback',{@datamanager.dataEdit 'replace' NaN},'Parent',figDataManagerBrush,'Serializable','off','HandleVisibility','off');
            uimenu('Label',menuLabels.getString('Label_figDataManagerReplaceConst'),'Visible',isMenuVisible,'Tag','figDataManagerReplaceConst','Callback',{@datamanager.dataEdit 'replace'},'Parent',figDataManagerBrush,'Serializable','off','HandleVisibility','off');
            
        uimenu('Label',menuLabels.getString('Label_figDataManagerRemove'),'Visible',isMenuVisible,'Tag','figDataManagerRemove','Callback',{@datamanager.dataEdit 'remove' false},'Parent',figDataManagerBrushTools,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figDataManagerRemoveUnbr'),'Visible',isMenuVisible,'Tag','figDataManagerRemoveUnbr','Callback',{@datamanager.dataEdit 'remove' true},'Parent',figDataManagerBrushTools,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figDataManagerNewVar'),'Visible',isMenuVisible,'Tag','figDataManagerNewVar','Callback',{@datamanager.newvar},'Parent',figDataManagerBrushTools,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figDataManagerPaste'),'Visible',isMenuVisible,'Tag','figDataManagerPaste','Callback',{@datamanager.paste},'Parent',figDataManagerBrushTools,'Separator','on','Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figDataManagerCopy'),'Visible',isMenuVisible,'Tag','figDataManagerCopy','Callback',{@datamanager.copySelection},'Parent',figDataManagerBrushTools,'Separator','on','Serializable','off','HandleVisibility','off');

    uimenu('Label',menuLabels.getString('Label_figMenuToolsBF'),'Visible',isMenuVisible,'Tag','figMenuToolsBF','Callback','toolsmenufcn BasicFitting','Parent',figMenuTools,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuToolsDS'),'Visible',isMenuVisible,'Tag','figMenuToolsDS','Callback','toolsmenufcn DataStatistics','Parent',figMenuTools,'Serializable','off','HandleVisibility','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Window menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
figMenuWindow = uimenu('Label',menuLabels.getString('Label_figMenuWindow'),'Visible',isMenuVisible,'Tag','figMenuWindow','Callback','winmenu(gcbo)','Parent',fig,'Serializable','off','HandleVisibility','off');
        
    winMenuBlank(1) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank1' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(2) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank2' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(3) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank3' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(4) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank4' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(5) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank5' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(6) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank6' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(7) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank7' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(8) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank8' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(9) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank9' ,'Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(10) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank10','Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    winMenuBlank(11) = uimenu('Label',menuLabels.getString('Label_winMenuBlank1'),'Tag','winMenuBlank11','Visible',isMenuVisible,'Parent',figMenuWindow,'Serializable','off','HandleVisibility','off');
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Help menu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
figMenuHelp = uimenu('Label',menuLabels.getString('Label_figMenuHelp'),'Visible',isMenuVisible,'Tag','figMenuHelp','Callback','helpmenufcn(gcbf,''HelpmenuPost'')','Parent',fig,'Serializable','off','HandleVisibility','off');

    uimenu('Label',menuLabels.getString('Label_figMenuHelpGraphics'),'Visible',isMenuVisible,'Tag','figMenuHelpGraphics','Callback','helpmenufcn(gcbf,''HelpGraphics'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpPlottingTools'),'Visible',isMenuVisible,'Tag','figMenuHelpPlottingTools','Callback','helpmenufcn(gcbf,''HelpPlottingTools'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpAnnotatingGraphs'),'Visible',isMenuVisible,'Tag','figMenuHelpAnnotatingGraphs','Callback','helpmenufcn(gcbf,''HelpAnnotatingGraphs'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpPrintingExport'),'Visible',isMenuVisible,'Tag','figMenuHelpPrintingExport','Callback','helpmenufcn(gcbf,''HelpPrintingExport'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    figMenuWeb = uimenu('Label',menuLabels.getString('Label_figMenuWeb'),'Visible',isMenuVisible,'Tag','figMenuWeb','Callback','webmenufcn WebmenuPost','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off','Separator','on');
    
        uimenu('Label',menuLabels.getString('Label_figMenuWebMathWorksHome'),'Visible',isMenuVisible,'Tag','figMenuWebMathWorksHome','Callback','webmenufcn MathWorksHome','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebStudentAccount'),'Visible',isMenuVisible,'Tag','figMenuWebStudentAccount','Callback','webmenufcn Login','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebProducts'),'Visible',isMenuVisible,'Tag','figMenuWebProducts','Callback','webmenufcn Products','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebTechSupport'),'Visible',isMenuVisible,'Tag','figMenuWebTechSupport','Callback','webmenufcn TechSupport','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebTraining'),'Visible',isMenuVisible,'Tag','figMenuWebTraining','Callback','webmenufcn Training','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebStudentFAQ'),'Visible',isMenuVisible,'Tag','figMenuWebStudentFAQ','Callback','webmenufcn StudentFAQ','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebStudentCenter'),'Visible',isMenuVisible,'Tag','figMenuWebStudentCenter','Callback','webmenufcn StudentCenter','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebStore'),'Visible',isMenuVisible,'Tag','figMenuWebStore','Callback','webmenufcn WebStore','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebLogin'),'Visible',isMenuVisible,'Tag','figMenuWebLogin','Callback','webmenufcn Login','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebMATLABCentral'),'Visible',isMenuVisible,'Tag','figMenuWebMATLABCentral','Callback','webmenufcn MATLABCentral','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off','Separator','on');
        uimenu('Label',menuLabels.getString('Label_figMenuWebFileExchange'),'Visible',isMenuVisible,'Tag','figMenuWebFileExchange','Callback','webmenufcn FileExchange','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebNewsgroupAccess'),'Visible',isMenuVisible,'Tag','figMenuWebNewsgroupAccess','Callback','webmenufcn NewsgroupAccess','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuWebNewsletters'),'Visible',isMenuVisible,'Tag','figMenuWebNewsletters','Callback','webmenufcn Newsletters','Parent',figMenuWeb,'Serializable','off','HandleVisibility','off');
        
    uimenu('Label',menuLabels.getString('Label_figMenuGetTrials'),'Visible',isMenuVisible,'Tag','figMenuGetTrials','Callback','webmenufcn Trials','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpUpdates'),'Visible',isMenuVisible,'Tag','figMenuHelpUpdates','Callback','webmenufcn CheckUpdates','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    figMenuTutorials = uimenu('Label',menuLabels.getString('Label_figMenuTutorials'),'Visible',isMenuVisible,'Tag','figMenuTutorials','Callback','%-----','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    
        uimenu('Label',menuLabels.getString('Label_figMenuTutorialsMATLAB'),'Visible',isMenuVisible,'Tag','figMenuTutorialsMATLAB','Callback','helpmenufcn(gcbf,''HelpMLTutorials'')','Parent',figMenuTutorials,'Serializable','off','HandleVisibility','off');
        uimenu('Label',menuLabels.getString('Label_figMenuTutorialsSimulink'),'Visible',isMenuVisible,'Tag','figMenuTutorialsSimulink','Callback','helpmenufcn(gcbf,''HelpSLTutorials'')','Parent',figMenuTutorials,'Serializable','off','HandleVisibility','off');
    
    uimenu('Label',menuLabels.getString('Label_figMenuDemos'),'Visible',isMenuVisible,'Tag','figMenuDemos','Callback','helpmenufcn(gcbf,''HelpDemos'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpActivation'),'Visible',isMenuVisible,'Tag','figMenuHelpActivation','Callback','helpmenufcn(gcbf,''HelpActivation'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off','Separator','on');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpTerms'),'Visible',isMenuVisible,'Tag','figMenuHelpTerms','Callback','helpmenufcn(gcbf,''HelpTerms'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpPatents'),'Visible',isMenuVisible,'Tag','figMenuHelpPatents','Callback','helpmenufcn(gcbf,''HelpPatents'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off');
    uimenu('Label',menuLabels.getString('Label_figMenuHelpAbout'),'Visible',isMenuVisible,'Tag','figMenuHelpAbout','Callback','helpmenufcn(gcbf,''HelpAbout'')','Parent',figMenuHelp,'Serializable','off','HandleVisibility','off','Separator','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF MENUS%%%%%%%%%%%%
   
% Find menu with the Window Menu Item ('Tag' = 'figMenuWindow'), and set it to Visible off.
set(winMenuBlank, 'Visible', 'off');
if ~deploy
    
    if (hg1figure)
        % g620911: prime the menu with its first item (hg1 figure only)
        set(winMenuBlank(1),'Label',getString(message('MATLAB:uistring:winmenu:MATLABCommandWindow')),...
            'Callback', '');
    end
    set(winMenuBlank(1), 'Visible', 'on');
    
    % Special Case: The Desktop menu is created here instead of the makemenu
    % structure because we need a CreateFcn for the Desktop menu.
    menupos = get(figMenuWindow, 'Position');
    figMenuDesktop = uimenu(fig,     'Label',        menuLabels.getString('Label_figMenuDesktop'), ...
        'Position',     menupos, ...
        'Callback',     'desktopmenufcn(gcbo, ''DesktopMenuPopulate'')', ...
        'Tag',          'figMenuDesktop' , ...
        'RequireJavaFigures',     'On',...
        'HandleVisibility','off',...
        'Serializable','off');
    
    result = [figMenuFile figMenuEdit figMenuView figMenuInsert figMenuTools figMenuDesktop figMenuWindow figMenuHelp];
    
else
    
    result = [figMenuFile figMenuEdit figMenuView figMenuInsert figMenuTools figMenuWindow figMenuHelp];
    
end

end

function s = SHARED_NEW_CALLBACK
s = 'filemenufcn(gcbf,''FileNew'')';
end

function s = SHARED_OPEN_CALLBACK
s = 'filemenufcn(gcbf,''FileOpen'')';
end

function s = SHARED_SAVE_CALLBACK
s = 'filemenufcn(gcbf,''FileSave'')';
end

function s = SHARED_PRINT_CALLBACK
s = 'printdlg(gcbf)';
end

function vis = isVisible(deployMode)
vis = 'on';
if (deployMode==1)
    vis = 'off';
end
end