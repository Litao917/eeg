function this = ImportWizard(parent)
% ImportWizard is the constructor of the class, which imports time series
% from an excel workbook into tstool

% Author: Rong Chen 
% Copyright 2004-2012 The MathWorks, Inc.

%--------------------------------------------------------------------------
% create a singleton of this import dialog
%--------------------------------------------------------------------------
mlock
persistent ImportWizardInstance;
if ischar(parent) && strcmpi(parent,'destroy')
    if isempty(ImportWizardInstance) || ~ishandle(ImportWizardInstance)
        ImportWizardInstance = tsguis.ImportWizard;
    end
    this = ImportWizardInstance;
    return
end
if isempty(ImportWizardInstance) || ~ishandle(ImportWizardInstance) 
    ImportWizardInstance = tsguis.ImportWizard;
    this = ImportWizardInstance; 
    this.Parent = parent;
else
    this = ImportWizardInstance;
    if ishghandle(this.Figure)
        set(this.Figure,'Visible','on');
        return
    end
end

ScreenSize=get(0,'ScreenSize');
if ScreenSize(3)<800 || ScreenSize(4)<600
    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:ImportWizardRequires800x600Resolution')),...
        getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));    
    return
end

% -------------------------------------------------------------------------
% load default position parameters for all the components
% -------------------------------------------------------------------------
this.defaultPositions

% -------------------------------------------------------------------------
% initialize figure window
% -------------------------------------------------------------------------
% create the main figure window
strTimeSeriesImportWiz = getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesImportWizard'));
this.Figure = figure('Name', strTimeSeriesImportWiz, ...
        'WindowStyle','normal', ...
        'Units', 'Pixels', ...
        'Toolbar', 'None', ...
        'Menubar', 'None', ...
        'NumberTitle', 'off', ...
        'HandleVisibility', 'Callback', ...
        'Position',[this.DefaultPos.Figure_leftoffset ...
                    this.DefaultPos.Figure_bottomoffset ...
                    this.DefaultPos.Figure_width ...
                    this.DefaultPos.Figure_height], ...
        'Visible', 'on',...
        'IntegerHandle','off','Tag','tsImportWizard');
% set figure callback function handle
set(this.Figure,'CloseRequestFcn',{@localCloseReq, this})

% -------------------------------------------------------------------------
% get default background colors for all components
% -------------------------------------------------------------------------
this.DefaultPos.FigureDefaultColor=get(this.Figure,'Color');
this.DefaultPos.EditDefaultColor=[1 1 1];

% -------------------------------------------------------------------------
% create buttons panel
% -------------------------------------------------------------------------
this.Handles.BTNback = uicontrol('Parent',this.Figure, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Back')),...
    'Position',[this.DefaultPos.leftoffsetBACKbtn ...
                this.DefaultPos.bottomoffsetbtn ...
                this.DefaultPos.widthbtn ...
                this.DefaultPos.heightbtn],...
    'Callback',{@localBACK this},...
    'BusyAction','cancel',...
    'Interruptible','off', 'Tag', 'BTNback');
this.Handles.BTNnext = uicontrol('Parent',this.Figure, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Next')),...
    'Position',[this.DefaultPos.leftoffsetNEXTbtn ...
                this.DefaultPos.bottomoffsetbtn ...
                this.DefaultPos.widthbtn ...
                this.DefaultPos.heightbtn],...
    'Callback',{@localNEXT this}, ...
    'BusyAction','cancel',...
    'Interruptible','off'...
    , 'Tag', 'BTNnext');
this.Handles.BTNcancel = uicontrol('Parent',this.Figure, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Cancel')), ...
    'Position',[this.DefaultPos.leftoffsetCANCELbtn ...
                this.DefaultPos.bottomoffsetbtn ...
                this.DefaultPos.widthbtn ...
                this.DefaultPos.heightbtn], ...
    'Callback',{@localCANCEL this} ...
    , 'Tag', 'BTNcancel');
this.Handles.BTNhelp = uicontrol('Parent',this.Figure, ...
    'style','pushbutton', ...
    'Units','Pixels', ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Help')),...
    'Position',[this.DefaultPos.leftoffsetHELPbtn ...
                this.DefaultPos.bottomoffsetbtn ...
                this.DefaultPos.widthbtn ...
                this.DefaultPos.heightbtn], ...
    'Callback','tsDispatchHelp(''its_wiz_about'',''modal'')' ...
    , 'Tag', 'BTNhelp');
set(this.Handles.BTNback,'Visible','off')

% -------------------------------------------------------------------------
% create instruction panel
% -------------------------------------------------------------------------
strCurrentStep = getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:CurrentStep'));
this.DefaultPos.InstructionPanelDefaultColor=this.DefaultPos.FigureDefaultColor;
this.Handles.PNLinstruction = uipanel('Parent',this.Figure, ...
    'Units','Pixels', ...
    'BackgroundColor',this.DefaultPos.InstructionPanelDefaultColor,...
    'Position', [this.DefaultPos.leftoffsetpnl this.DefaultPos.bottomoffsetInstructionpnl ...
                this.DefaultPos.widthpnl this.DefaultPos.heightInstructionpnl], ...
    'Title',sprintf(' %s ',strCurrentStep));
this.Handles.TXTstep3 = uicontrol('Parent',this.Handles.PNLinstruction, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',this.DefaultPos.InstructionPanelDefaultColor, ...
    'ForegroundColor',[0.7 0.7 0.7], ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Step3CreateTimeseriesObjectsAndImport')), ...
    'FontWeight','bold', ...
    'HorizontalAlignment','Left', ...
    'Position',[this.DefaultPos.leftoffsetTXT ...
                this.DefaultPos.bottomoffsetTXT3 ...
                this.DefaultPos.widthTXT ...
                this.DefaultPos.heighttxt] ...
    , 'Tag', 'TXTstep3');
this.Handles.TXTstep2 = uicontrol('Parent',this.Handles.PNLinstruction, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',this.DefaultPos.InstructionPanelDefaultColor, ...
    'ForegroundColor',[0.7 0.7 0.7], ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Step2SpecifyDataAndTime')), ...
    'FontWeight','bold', ...
    'HorizontalAlignment','Left', ...
    'Position',[this.DefaultPos.leftoffsetTXT ...
                this.DefaultPos.bottomoffsetTXT2 ...
                this.DefaultPos.widthTXT ...
                this.DefaultPos.heighttxt] ...
    , 'Tag', 'TXTstep2');
this.Handles.TXTstep1 = uicontrol('Parent',this.Handles.PNLinstruction, ...
    'style','text', ...
    'Units','Pixels', ...
    'BackgroundColor',this.DefaultPos.InstructionPanelDefaultColor, ...
    'ForegroundColor',[0 0 0], ...
    'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Step1ChooseSourceWithTimeseriesData')), ...
    'FontWeight','bold', ...
    'HorizontalAlignment','Left', ...
    'Position',[this.DefaultPos.leftoffsetTXT ...
                this.DefaultPos.bottomoffsetTXT1 ...
                this.DefaultPos.widthTXT ...
                this.DefaultPos.heighttxt] ...
    , 'Tag', 'TXTstep1');

% -------------------------------------------------------------------------
%% create step 2 and 3 panels
% -------------------------------------------------------------------------
set(this.Figure,'Pointer','watch');
if ispc && ~isfield(this.DefaultPos,'actxProgID')
    actxlist=actxcontrollist;
    actxindex=strfind(actxlist(:,1),'Microsoft Office Spreadsheet');
    this.DefaultPos.actxProgID=sort(actxlist(not(cellfun('isempty',actxindex)),2));
end
this.Handles.exceldlg = tsguis.excelImportdlg(this);
this.Handles.csvdlg = tsguis.csvImportdlg(this);
this.Handles.matdlg = tsguis.matImportdlg(this);
this.Handles.workspacedlg = tsguis.workspaceImportdlg(this);
set(this.Figure,'Pointer','arrow');

% -------------------------------------------------------------------------
%% load panel for Step 1 :  source selection
% -------------------------------------------------------------------------
this.initializeSourcePanel;
this.initializeOptionPanel;
this.Step=1;

% use customized resize function
set(this.Figure,'ResizeFcn',{@localFigResize, this});


this.DestroyListener = handle.listener(this,'ObjectBeingDestroyed',@localDelete);

function localDelete(this,~)

if ~isempty(this.Handles.exceldlg) && ishandle(this.Handles.exceldlg)
    delete(this.Handles.exceldlg)
end
if ~isempty(this.Handles.csvdlg) && ishandle(this.Handles.csvdlg)
    delete(this.Handles.csvdlg)
end
if ~isempty(this.Handles.matdlg) && ishandle(this.Handles.matdlg)
    delete(this.Handles.matdlg)
end
if ~isempty(this.Handles.workspacedlg) && ishandle(this.Handles.workspacedlg)
    delete(this.Handles.workspacedlg)
end


function localBACK(~,~, h)
% callback for the Next/Finish button

[~,~,fileExtension] = ...
    fileparts(deblank(get(h.Handles.EDTbrowser,'String')));
switch h.Step
    case 1
        % step 1
    case 2
        set(h.Handles.BTNnext,'Enable','on')
        % leave step 2 and enter step 1 
        % update the dialog title
        set(h.Figure,'Name',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesImportWizard')));
        % make source panel visible
        set(h.Handles.PNLsource,'Visible','on');
        % others
        set(h.Handles.BTNback,'Visible','off');
        set(h.Handles.TXTstep2,'ForegroundColor',[0.7 0.7 0.7]);
        set(h.Handles.TXTstep1,'ForegroundColor',[0 0 0]);
        % update step number
        h.Step=h.Step-1;
        % make table invisible        
        choice=get(h.Handles.COMBsource,'Value');
        switch choice
            case 1
                % excel
                if ~isempty(h.Handles.exceldlg.Handles.tsTable)
                    set(h.Handles.exceldlg.Handles.tsTablePanel,'Visible','off');
                end
                % make data panel and time panel invisible        
                if isfield(h.Handles.exceldlg.Handles,'PNLdata')
                    set(h.Handles.exceldlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.exceldlg.Handles,'PNLtime')
                    set(h.Handles.exceldlg.Handles.PNLtime,'Visible','off');
                end              
            case 2
                % csv
                if ~isempty(h.Handles.csvdlg.Handles.tsTable)
                    set(h.Handles.csvdlg.Handles.tsTablePanel,'Visible','off')
                end
                % make data panel and time panel invisible        
                if isfield(h.Handles.csvdlg.Handles,'PNLdata')
                    set(h.Handles.csvdlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.csvdlg.Handles,'PNLtime')
                    set(h.Handles.csvdlg.Handles.PNLtime,'Visible','off');
                end                
            case 3
                % mat
                set(h.Handles.matdlg.Handles.jBrowser,'Visible','off'); %508
                % make data panel and time panel invisible        
                if isfield(h.Handles.matdlg.Handles,'PNLdata')
                    set(h.Handles.matdlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.matdlg.Handles,'PNLtime')
                    set(h.Handles.matdlg.Handles.PNLtime,'Visible','off');
                end
            case 4
                % workspace
                set(h.Handles.workspacedlg.Handles.jBrowser,'Visible','off'); %508
                % make data panel and time panel invisible        
                if isfield(h.Handles.workspacedlg.Handles,'PNLdata')
                    set(h.Handles.workspacedlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.workspacedlg.Handles,'PNLtime')
                    set(h.Handles.workspacedlg.Handles.PNLtime,'Visible','off');
                end
        end
    case 3
        % leave step 3 and enter Step 2 
        % make option panel invisible
        set(h.Handles.PNLoption,'Visible','off');
        % others
        set(h.Handles.BTNnext,'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Next')));
        set(h.Handles.TXTstep3,'ForegroundColor',[0.7 0.7 0.7]);
        set(h.Handles.TXTstep2,'ForegroundColor',[0 0 0]);
        % update step number
        h.Step=h.Step-1;
        % make table visible
        choice=get(h.Handles.COMBsource,'Value');
        switch choice
            case 1
                % excel
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.xls')
                    if ~isempty(h.Handles.exceldlg.Handles.tsTable)
                        set(h.Handles.exceldlg.Handles.tsTablePanel,'Position',...
                           [h.Handles.exceldlg.DefaultPos.Table_leftoffset ...
                            h.Handles.exceldlg.DefaultPos.Table_bottomoffset+28 ...
                            h.Handles.exceldlg.DefaultPos.Table_width ...
                            h.Handles.exceldlg.DefaultPos.Table_height-28],...
                            'Visible','on');
                    end
                end
                % make data panel and time panel visible
                if isfield(h.Handles.exceldlg.Handles,'PNLdata')
                    set(h.Handles.exceldlg.Handles.PNLdata,'Visible','on');
                end
                if isfield(h.Handles.exceldlg.Handles,'PNLtime')
                    set(h.Handles.exceldlg.Handles.PNLtime,'Visible','on');
                end
                
           case 2
                % csv
                if ~isempty(fileExtension) && any(strcmpi(fileExtension,{'.csv','.txt','.dat'})) && ...
                        ~isempty(h.Handles.csvdlg.Handles.tsTable)
                    set(h.Handles.csvdlg.Handles.tsTablePanel,'Visible','on')
                end
                % make data panel and time panel visible
                if isfield(h.Handles.csvdlg.Handles,'PNLdata')
                    set(h.Handles.csvdlg.Handles.PNLdata,'Visible','on');
                end
                if isfield(h.Handles.csvdlg.Handles,'PNLtime')
                    set(h.Handles.csvdlg.Handles.PNLtime,'Visible','on');
                end
                
            case 3
                % mat
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.mat')
                    set(h.Handles.matdlg.Handles.jBrowser,'Position', ...
                         [h.Handles.matdlg.DefaultPos.activexleftoffset ...
                         h.Handles.matdlg.DefaultPos.activexbottomoffset ...
                         h.Handles.matdlg.DefaultPos.Table_width ...
                         h.Handles.matdlg.DefaultPos.Table_height],...
                         'Visible','on');
                end
                if isfield(h.Handles.matdlg.Handles,'PNLdata')
                    set(h.Handles.matdlg.Handles.PNLdata,'Visible','on');
                end
                if isfield(h.Handles.matdlg.Handles,'PNLtime')
                    set(h.Handles.matdlg.Handles.PNLtime,'Visible','on');
                end
            case 4
                % workspace
                set(h.Handles.workspacedlg.Handles.jBrowser,'Position', ...
                    [h.Handles.workspacedlg.DefaultPos.activexleftoffset ...
                     h.Handles.workspacedlg.DefaultPos.activexbottomoffset ...
                     h.Handles.workspacedlg.DefaultPos.Table_width ...
                     h.Handles.workspacedlg.DefaultPos.Table_height],...
                     'Visible','on');
                if isfield(h.Handles.workspacedlg.Handles,'PNLdata')
                    set(h.Handles.workspacedlg.Handles.PNLdata,'Visible','on');
                end
                if isfield(h.Handles.workspacedlg.Handles,'PNLtime')
                    set(h.Handles.workspacedlg.Handles.PNLtime,'Visible','on');
                end
         end
end


function localNEXT(~,~, h)
% callback for the Next/Finish button

[filePath,fileName,fileExtension] = fileparts(deblank(get(h.Handles.EDTbrowser,'String')));
switch h.Step
    case 1
        % leave step 1 and enter step 2
        choice=get(h.Handles.COMBsource,'Value');
        
        % check if there is a string in the editbox
        if choice == 1 || choice == 2
            if (choice==1 && ~strcmpi(fileExtension,'.xls')) || ...
                    (choice==2 && ~strcmpi(fileExtension,'.txt') && ...
                    ~strcmpi(fileExtension,'.csv') && ~strcmpi(fileExtension,'.dat'))
                errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:InvalidFileNameOrExtension')),...
                    getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal')
                return
            end
                
            if isempty(fileName)
                errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:FileNameNotSpecified')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                return
            else
                if isempty(fileExtension)
                    if choice == 1
                        fileExtension='.xls';
                    elseif choice == 2
                        fileExtension='.mat';
                    end
                end
                if isempty(dir(fullfile(filePath,[fileName fileExtension])))
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:FileDoesNotExist')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                    return
                end
            end
        elseif choice==3 && ~strcmpi(fileExtension,'.mat') 
                errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:InvalidFileNameOrExtension')),...
                    getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal')
                return
        end
            
        % Open the file
        if isempty(filePath)
           filePath = pwd;
        end
        status = localOpenFile(h,filePath,fileName,fileExtension);
        if ~status
            return
        end
        % make source panel invisible
        set(h.Handles.PNLsource,'Visible','off');
        % update step number
        h.Step=h.Step+1;
        % initialize table data panel and time panel
        switch choice
            case 1
                flag = h.Handles.exceldlg.initialize(fullfile(filePath,[fileName fileExtension]));
            case 2
                flag = h.Handles.csvdlg.initialize(fullfile(filePath,[fileName fileExtension]));
            case 3
                % mat
                flag=h.Handles.matdlg.initialize(fullfile(filePath,[fileName fileExtension]));
                if isempty(h.Handles.matdlg.Handles.Browser.getSelectedVarInfo)
                    set(h.Handles.BTNnext,'Enable','off')
                end
            case 4 
                % workspace
                flag=h.Handles.workspacedlg.initialize;
                if isempty(h.Handles.workspacedlg.Handles.Browser.getSelectedVarInfo)
                    set(h.Handles.BTNnext,'Enable','off')
                end
        end
        % others
        set(h.Handles.BTNback,'Visible','on');
        set(h.Handles.TXTstep1,'ForegroundColor',[0.7 0.7 0.7]);
        set(h.Handles.TXTstep2,'ForegroundColor',[0 0 0]);
        if ~flag
            % initialization fails, return the step 1
            localBACK([], [], h);
        end
    case 2
        % leave step 2 and enter Step 3 
        choice=get(h.Handles.COMBsource,'Value');
        switch choice
            case 1
                % excel
                if (isempty(get(h.Handles.exceldlg.Handles.EDTtimeSheetStart,'String')) || ...
                   isempty(get(h.Handles.exceldlg.Handles.EDTtimeSheetEnd,'String'))) && ...
                   get(h.Handles.exceldlg.Handles.COMBtimeSource,'Value')==1
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:SelectedTimesInvalid')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
                    return
                end
                if isempty(h.Handles.exceldlg.IOData.SelectedRows) || isempty(h.Handles.exceldlg.IOData.SelectedColumns)
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:NoDataBlockSelected')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                    return
                end
            % csv
            case 2
                if (isempty(get(h.Handles.csvdlg.Handles.EDTtimeSheetStart,'String')) || ...
                   isempty(get(h.Handles.csvdlg.Handles.EDTtimeSheetEnd,'String'))) && ...
                   get(h.Handles.csvdlg.Handles.COMBtimeSource,'Value')==1
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:SelectedTimesInvalid')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
                    return
                end
                if isempty(h.Handles.csvdlg.IOData.SelectedRows) || isempty(h.Handles.csvdlg.IOData.SelectedColumns)
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:NoDataBlockSelected')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                    return
                end
            case 3
                % mat
                if (isempty(get(h.Handles.matdlg.Handles.EDTtimeSheetStart,'String')) || ...
                   isempty(get(h.Handles.matdlg.Handles.EDTtimeSheetEnd,'String'))) && ...
                   get(h.Handles.matdlg.Handles.COMBtimeSource,'Value')==1
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:SelectedTimesInvalid')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
                    return
                end
                if ~isfield(h.Handles.matdlg.IOData.SelectedVariableInfo,'varname') || ...
                        isempty(h.Handles.matdlg.IOData.SelectedVariableInfo.varname)
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:NoVariableSelected')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                    return
                end
            case 4
                % workspace
                if (isempty(get(h.Handles.workspacedlg.Handles.EDTtimeSheetStart,'String')) || ...
                   isempty(get(h.Handles.workspacedlg.Handles.EDTtimeSheetEnd,'String'))) && ...
                   get(h.Handles.workspacedlg.Handles.COMBtimeSource,'Value')==1
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:SelectedTimesInvalid')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
                    return
                end
                if ~isfield(h.Handles.workspacedlg.IOData.SelectedVariableInfo,'varname') || ...
                        isempty(h.Handles.workspacedlg.IOData.SelectedVariableInfo.varname)
                    errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:NoVariableSelected')),getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')));
                    return
                end
        end
        % others
        set(h.Handles.BTNnext,'String',getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:Finish')));
        set(h.Handles.TXTstep2,'ForegroundColor',[0.7 0.7 0.7]);
        set(h.Handles.TXTstep3,'ForegroundColor',[0 0 0]);
        % update step number
        h.Step=h.Step+1;
        % disable table
        switch choice
            case 1
                % excel
                if ~isempty(h.Handles.exceldlg.Handles.tsTable)
                    set(h.Handles.exceldlg.Handles.tsTablePanel,'Visible','off');
                end
                % make data panel and time panel invisible
                if isfield(h.Handles.exceldlg.Handles,'PNLdata')
                    set(h.Handles.exceldlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.exceldlg.Handles,'PNLtime')
                    set(h.Handles.exceldlg.Handles.PNLtime,'Visible','off');
                end
                % make option panel visible
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.xls')
                    set(h.Handles.PNLoption,'Visible','on');
                end
            case 2
                % csv
                set(h.Handles.csvdlg.Handles.tsTablePanel,'Visible','off')
                % make data panel and time panel invisible
                if isfield(h.Handles.csvdlg.Handles,'PNLdata')
                    set(h.Handles.csvdlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.csvdlg.Handles,'PNLtime')
                    set(h.Handles.csvdlg.Handles.PNLtime,'Visible','off');
                end
                % make option panel visible
                if ~isempty(fileExtension) && any(strcmpi(fileExtension,{'.csv','.txt','.dat'}))
                    set(h.Handles.PNLoption,'Visible','on');
                end
            case 3
                % mat
                set(h.Handles.matdlg.Handles.jBrowser,'Visible','off');
                % make data panel and time panel invisible        
                if isfield(h.Handles.matdlg.Handles,'PNLdata')
                    set(h.Handles.matdlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.matdlg.Handles,'PNLtime')
                    set(h.Handles.matdlg.Handles.PNLtime,'Visible','off');
                end
                % make option panel visible
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.mat')
                    set(h.Handles.PNLoption,'Visible','on');
                end
                set(h.Handles.EDTsingleNEW,'String',h.Handles.matdlg.IOData.SelectedVariableInfo.varname);
                if get(h.Handles.COMBmultipleNEW,'Value')==2
                    set(h.Handles.EDTmultipleNEW,'String',h.Handles.matdlg.IOData.SelectedVariableInfo.varname);
                end
                set(h.Handles.COMBmultipleNEW,'Value',2);
                BtnNewCB = get(h.Handles.COMBmultipleNEW,'Callback');
                BtnNewCB{1}([],2,h);
            case 4
                % workspace
                set(h.Handles.workspacedlg.Handles.jBrowser,'Visible','off');
                % make data panel and time panel invisible        
                if isfield(h.Handles.workspacedlg.Handles,'PNLdata')
                    set(h.Handles.workspacedlg.Handles.PNLdata,'Visible','off');
                end
                if isfield(h.Handles.workspacedlg.Handles,'PNLtime')
                    set(h.Handles.workspacedlg.Handles.PNLtime,'Visible','off');
                end
                % make option panel visible
                set(h.Handles.PNLoption,'Visible','on');
                set(h.Handles.EDTsingleNEW,'String',h.Handles.workspacedlg.IOData.SelectedVariableInfo.varname);
                if get(h.Handles.COMBmultipleNEW,'Value')==2
                    set(h.Handles.EDTmultipleNEW,'String',h.Handles.workspacedlg.IOData.SelectedVariableInfo.varname);
                end
                set(h.Handles.COMBmultipleNEW,'Value',2);
                BtnNewCB = get(h.Handles.COMBmultipleNEW,'Callback');
                BtnNewCB{1}([],2,h);
        end
    case 3
        % leave step 3 and import
        choice=get(h.Handles.COMBsource,'Value');
        switch choice
            case 1
                % excel
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.xls')
                    if (h.Handles.exceldlg.savets)
                        localBACK([], [], h);
                        localBACK([], [], h);
                        set(h.Figure,'Visible','off');
                    end
                end
                h.Handles.exceldlg.IOData.FileName = '';
                
            case 2
                % csv
                if ~isempty(fileExtension) && any(strcmpi(fileExtension,{'.csv','.txt','.dat'}))
                    if (h.Handles.csvdlg.savets)
                        localBACK([], [], h);
                        localBACK([], [], h);
                        set(h.Figure,'Visible','off');
                    end
                end
                h.Handles.exceldlg.IOData.FileName = '';
                
            case 3
                % mat
                if ~isempty(fileExtension) && strcmpi(fileExtension,'.mat')
                    if (h.Handles.matdlg.savets)
                        %delete(h.Figure);
                        localBACK([], [], h);
                        localBACK([], [], h);
                        set(h.Figure,'Visible','off');
                    end
                end
            case 4
                % workspace
                if (h.Handles.workspacedlg.savets)
                    %delete(h.Figure);
                    localBACK([], [], h);
                    localBACK([], [], h);
                    set(h.Figure,'Visible','off');
                end
        end
end
    

function localCANCEL(~,~, h)
% callback for the CANCEL button

choice=get(h.Handles.COMBsource,'Value');
switch choice
    case 1
        % excel
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
        h.Handles.exceldlg.IOData.FileName = ''; 
      case 2
        % csv
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
        h.Handles.csvdlg.IOData.FileName = '';         
    case 3
        % mat
        % delete(h.Figure);
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
    case 4
        % workspace
        % delete(h.Figure);
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
end


function localCloseReq(~,~, h)
% overwrite the exit function for the figure window
% Note: figure window won't be deleted unless the import dialog is deleted

choice=get(h.Handles.COMBsource,'Value');
switch choice
    case 1
        % excel
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
   case 2
        % csv
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');    
    case 3
        % mat
        % delete(this.Figure);
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
    case 4
        % workspace
        % delete(this.Figure);
        localBACK([], [], h);
        localBACK([], [], h);
        set(h.Figure,'Visible','off');
end



function localFigResize(eventSrc, ~, this)
% callback for the resize function in the figure window

% -------------------------------------------------------------------------
% Components and panels are repositioned relative to the main panel
% the minimum size of the figure window is 800*600 by default
% -------------------------------------------------------------------------
mainpnlpos = tsgetposition(eventSrc,'Pixels');
this.ScreenSize=get(0,'ScreenSize');
mainpnlpos(1)=min(mainpnlpos(1),max(this.ScreenSize(3)-595,0));%775
mainpnlpos(2)=min(mainpnlpos(2),max(this.ScreenSize(4)-431,0));%575
mainpnlpos(3)=max(576,mainpnlpos(3));% 750
mainpnlpos(4)=max(412,mainpnlpos(4)); % 550
set(this.Figure,'Position',mainpnlpos);
% -------------------------------------------------------------------------
% button
% -------------------------------------------------------------------------
this.DefaultPos.leftoffsetBACKbtn=max(1,mainpnlpos(3)-4*this.DefaultPos.widthbtn-3*this.DefaultPos.separation-60);
this.DefaultPos.leftoffsetNEXTbtn=max(1,mainpnlpos(3)-3*this.DefaultPos.widthbtn-2*this.DefaultPos.separation-60);
this.DefaultPos.leftoffsetCANCELbtn=max(1,mainpnlpos(3)-2*this.DefaultPos.widthbtn-this.DefaultPos.separation-30);
this.DefaultPos.leftoffsetHELPbtn=max(1,mainpnlpos(3)-1*this.DefaultPos.widthbtn-30);
set(this.Handles.BTNback,'Position',[this.DefaultPos.leftoffsetBACKbtn this.DefaultPos.bottomoffsetbtn this.DefaultPos.widthbtn this.DefaultPos.heightbtn]);
set(this.Handles.BTNnext,'Position',[this.DefaultPos.leftoffsetNEXTbtn this.DefaultPos.bottomoffsetbtn this.DefaultPos.widthbtn this.DefaultPos.heightbtn]);
set(this.Handles.BTNcancel,'Position',[this.DefaultPos.leftoffsetCANCELbtn this.DefaultPos.bottomoffsetbtn this.DefaultPos.widthbtn this.DefaultPos.heightbtn]);
set(this.Handles.BTNhelp,'Position',[this.DefaultPos.leftoffsetHELPbtn this.DefaultPos.bottomoffsetbtn this.DefaultPos.widthbtn this.DefaultPos.heightbtn]);
% -------------------------------------------------------------------------
% panels
% -------------------------------------------------------------------------
this.DefaultPos.widthpnl=mainpnlpos(3)-2*this.DefaultPos.leftoffsetpnl;
% -------------------------------------------------------------------------
% instruction panel
% -------------------------------------------------------------------------
this.DefaultPos.bottomoffsetInstructionpnl=mainpnlpos(4)-this.DefaultPos.heightInstructionpnl-this.DefaultPos.separation;
set(this.Handles.PNLinstruction,'Position',[this.DefaultPos.leftoffsetpnl ...
                                    this.DefaultPos.bottomoffsetInstructionpnl ...
                                    max(1,this.DefaultPos.widthpnl) ...
                                    this.DefaultPos.heightInstructionpnl]);
% -------------------------------------------------------------------------
% all dynamic panels
% -------------------------------------------------------------------------
this.DefaultPos.widthDynamicPnl=this.DefaultPos.widthpnl;
this.DefaultPos.heightDynamicPnl=this.DefaultPos.bottomoffsetInstructionpnl-this.DefaultPos.buttomoffsetDynamicPnl-this.DefaultPos.separation-8;
% -------------------------------------------------------------------------
% step 1: source panel
% -------------------------------------------------------------------------
if isfield(this.Handles,'PNLsource')
    width_TXT = 100;
    width_WIDGET = 325;
    set(this.Handles.PNLsource,'Position',[this.DefaultPos.leftoffsetDynamicPnl ...
                this.DefaultPos.buttomoffsetDynamicPnl ...
                this.DefaultPos.widthDynamicPnl ...
                this.DefaultPos.heightDynamicPnl]);
    set(this.Handles.TXTsource,'Position',[20 this.DefaultPos.heightDynamicPnl-60 width_TXT this.DefaultPos.heighttxt]);
    set(this.Handles.COMBsource,'Position',[20+width_TXT+10 this.DefaultPos.heightDynamicPnl-56 width_WIDGET this.DefaultPos.heightcomb]);
    set(this.Handles.TXTbrowser,'Position',[20 this.DefaultPos.heightDynamicPnl-100 width_TXT this.DefaultPos.heighttxt]);
    set(this.Handles.EDTbrowser,'Position',[20+width_TXT+10 this.DefaultPos.heightDynamicPnl-100 width_WIDGET this.DefaultPos.heightedt]);
    set(this.Handles.BTNbrowser,'Position',[20+width_TXT+10+width_WIDGET+20 this.DefaultPos.heightDynamicPnl-103 this.DefaultPos.widthbtn this.DefaultPos.heightbtn]);
end
% -------------------------------------------------------------------------
% run default position for sub-dialogs
% -------------------------------------------------------------------------
this.Handles.exceldlg.defaultPositions;
this.Handles.csvdlg.defaultPositions;
this.Handles.matdlg.defaultPositions;
this.Handles.workspacedlg.defaultPositions;
% -------------------------------------------------------------------------
% step 2
% -------------------------------------------------------------------------
choice=get(this.Handles.COMBsource,'Value');
% excel
% -------------------------------------------------------------------------
% time panel
% -------------------------------------------------------------------------
if isfield(this.Handles.exceldlg.Handles,'PNLtime')
set(this.Handles.exceldlg.Handles.PNLtime,'Position',...
   [this.Handles.exceldlg.DefaultPos.leftoffsetpnl ...
    this.Handles.exceldlg.DefaultPos.bottomoffsetTimepnl ...
    this.Handles.exceldlg.DefaultPos.widthpnl ...
    this.Handles.exceldlg.DefaultPos.heightTimepnl]);
set(this.Handles.exceldlg.Handles.PNLtimeCurrentSheet,'Position',[5 5 ...
    this.Handles.exceldlg.DefaultPos.widthpnl-10 ...
    this.Handles.exceldlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.exceldlg.DefaultPos.separation-5]);
set(this.Handles.exceldlg.Handles.PNLtimeManual,'Position',[5 5 ...
    this.Handles.exceldlg.DefaultPos.widthpnl-10 ...
    this.Handles.exceldlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.exceldlg.DefaultPos.separation-5]);
end
if isfield(this.Handles.csvdlg.Handles,'PNLtime')
    set(this.Handles.csvdlg.Handles.PNLtime,'Position',...
       [this.Handles.csvdlg.DefaultPos.leftoffsetpnl ...
        this.Handles.csvdlg.DefaultPos.bottomoffsetTimepnl ...
        this.Handles.csvdlg.DefaultPos.widthpnl ...
        this.Handles.csvdlg.DefaultPos.heightTimepnl]);
    set(this.Handles.csvdlg.Handles.PNLtimeCurrentSheet,'Position',[5 5 ...
        this.Handles.csvdlg.DefaultPos.widthpnl-10 ...
        this.Handles.csvdlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.csvdlg.DefaultPos.separation-5]);
    set(this.Handles.csvdlg.Handles.PNLtimeManual,'Position',[5 5 ...
        this.Handles.csvdlg.DefaultPos.widthpnl-10 ...
        this.Handles.csvdlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.csvdlg.DefaultPos.separation-5]);
end
% -------------------------------------------------------------------------
% data panel
% -------------------------------------------------------------------------
if isfield(this.Handles.exceldlg.Handles,'PNLdata')
    set(this.Handles.exceldlg.Handles.PNLdata,'Position',...
        [this.Handles.exceldlg.DefaultPos.leftoffsetpnl ...
         this.Handles.exceldlg.DefaultPos.bottomoffsetDatapnl ...
         this.Handles.exceldlg.DefaultPos.widthpnl ...
         this.Handles.exceldlg.DefaultPos.heightDatapnl]);

    if this.Step==2 && choice==1
        set(this.Handles.exceldlg.Handles.tsTablePanel,'Position', [this.Handles.exceldlg.DefaultPos.Table_leftoffset ...
                                            this.Handles.exceldlg.DefaultPos.Table_bottomoffset+28 ...
                                            this.Handles.exceldlg.DefaultPos.Table_width ...
                                            this.Handles.exceldlg.DefaultPos.Table_height-28]);
    end

end
if isfield(this.Handles.csvdlg.Handles,'PNLdata')
    set(this.Handles.csvdlg.Handles.PNLdata,'Position',...
        [this.Handles.csvdlg.DefaultPos.leftoffsetpnl ...
         this.Handles.csvdlg.DefaultPos.bottomoffsetDatapnl ...
         this.Handles.csvdlg.DefaultPos.widthpnl ...
         this.Handles.csvdlg.DefaultPos.heightDatapnl]);
    if this.Step==2 && choice==2
        set(this.Handles.csvdlg.Handles.tsTablePanel,'Position',...
            [this.Handles.csvdlg.DefaultPos.Table_leftoffset ...
             this.Handles.csvdlg.DefaultPos.Table_bottomoffset+28 ...
             this.Handles.csvdlg.DefaultPos.Table_width ...
             max(this.Handles.csvdlg.DefaultPos.Table_height-28,5)],...
             'Visible','on');
    end

end

% mat
% -------------------------------------------------------------------------
% time panel
% -------------------------------------------------------------------------
if isfield(this.Handles.matdlg.Handles,'PNLtime')
    set(this.Handles.matdlg.Handles.PNLtime,'Position', ...
       [this.Handles.matdlg.DefaultPos.leftoffsetpnl ...
        this.Handles.matdlg.DefaultPos.bottomoffsetTimepnl ...
        this.Handles.matdlg.DefaultPos.widthpnl ...
        this.Handles.matdlg.DefaultPos.heightTimepnl]);
    set(this.Handles.matdlg.Handles.PNLtimeCurrentSheet,'Position',[5 5 ...
        this.Handles.matdlg.DefaultPos.widthpnl-10 ...
        this.Handles.matdlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.matdlg.DefaultPos.separation-5]);
    set(this.Handles.matdlg.Handles.PNLtimeManual,'Position',[5 5 ...
        this.Handles.matdlg.DefaultPos.widthpnl-10 ...
        this.Handles.matdlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.matdlg.DefaultPos.separation-5]);
end
% -------------------------------------------------------------------------
% data panel
% -------------------------------------------------------------------------
if isfield(this.Handles.matdlg.Handles,'PNLdata')
    set(this.Handles.matdlg.Handles.PNLdata,'Position', ...
       [this.Handles.matdlg.DefaultPos.leftoffsetpnl ...
        this.Handles.matdlg.DefaultPos.bottomoffsetDatapnl ...
        this.Handles.matdlg.DefaultPos.widthpnl ...
        this.Handles.matdlg.DefaultPos.heightDatapnl]);
    if this.Step==2  && choice==3%2 jgo
        set(this.Handles.matdlg.Handles.jBrowser,'Position', ...
            [this.Handles.matdlg.DefaultPos.Table_leftoffset ...
             this.Handles.matdlg.DefaultPos.Table_bottomoffset ...
             this.Handles.matdlg.DefaultPos.Table_width ...
             this.Handles.matdlg.DefaultPos.Table_height],...
             'Visible','on');
    end
    set(this.Handles.matdlg.Handles.BTNrefresh,'Position', ...
            [this.Handles.matdlg.DefaultPos.widthpnl-90-20 ...
             this.Handles.matdlg.DefaultPos.TXTdataSamplebottomoffset+4 ...
             90 ...
             this.Handles.matdlg.DefaultPos.heightbtn]);
end
% workspace
% -------------------------------------------------------------------------
% time panel
% -------------------------------------------------------------------------
if isfield(this.Handles.workspacedlg.Handles,'PNLtime')
    set(this.Handles.workspacedlg.Handles.PNLtime,'Position', ...
       [this.Handles.workspacedlg.DefaultPos.leftoffsetpnl ...
        this.Handles.workspacedlg.DefaultPos.bottomoffsetTimepnl ...
        this.Handles.workspacedlg.DefaultPos.widthpnl ...
        this.Handles.workspacedlg.DefaultPos.heightTimepnl]);
    set(this.Handles.workspacedlg.Handles.PNLtimeCurrentSheet,'Position',[5 5 ...
        this.Handles.workspacedlg.DefaultPos.widthpnl-10 ...
        this.Handles.workspacedlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.workspacedlg.DefaultPos.separation-5]);
    set(this.Handles.workspacedlg.Handles.PNLtimeManual,'Position',[5 5 ...
        this.Handles.matdlg.DefaultPos.widthpnl-10 ...
        this.Handles.workspacedlg.DefaultPos.TXTtimeSheetbottomoffset-this.Handles.workspacedlg.DefaultPos.separation-5]);
    if this.Step==2 && choice==4
        set(this.Handles.workspacedlg.Handles.jBrowser,'Position', ...
            [this.Handles.workspacedlg.DefaultPos.Table_leftoffset ...
             this.Handles.workspacedlg.DefaultPos.Table_bottomoffset ...
             this.Handles.workspacedlg.DefaultPos.Table_width ...
             this.Handles.workspacedlg.DefaultPos.Table_height],...
             'Visible','on');
    end
    set(this.Handles.workspacedlg.Handles.BTNrefresh,'Position',[this.Handles.workspacedlg.DefaultPos.widthpnl-90-20 ...
                this.Handles.workspacedlg.DefaultPos.TXTdataSamplebottomoffset+4 ...
                90 ...
                this.Handles.workspacedlg.DefaultPos.heightbtn]);
end
% -------------------------------------------------------------------------
% data panel
% -------------------------------------------------------------------------
if isfield(this.Handles.workspacedlg.Handles,'PNLdata')
    set(this.Handles.workspacedlg.Handles.PNLdata,'Position', ...
       [this.Handles.workspacedlg.DefaultPos.leftoffsetpnl ...
        this.Handles.workspacedlg.DefaultPos.bottomoffsetDatapnl ...
        this.Handles.workspacedlg.DefaultPos.widthpnl ...
        this.Handles.workspacedlg.DefaultPos.heightDatapnl]);
%     if this.Step==2  && choice==3
%         set(this.Handles.workspacedlg.Handles.jBrowser,'Position', ...
%             [this.Handles.workspacedlg.DefaultPos.Table_leftoffset ...
%              this.Handles.workspacedlg.DefaultPos.Table_bottomoffset ...
%              this.Handles.workspacedlg.DefaultPos.Table_width ...
%              this.Handles.workspacedlg.DefaultPos.Table_height]);
%         set(this.Handles.workspacedlg.Handles.BTNrefresh,'Position', ...
%             [this.Handles.workspacedlg.DefaultPos.widthpnl-90-20 ...
%              this.Handles.workspacedlg.DefaultPos.TXTdataSamplebottomoffset+4 ...
%              90 ...
%              this.Handles.workspacedlg.DefaultPos.heightbtn]);
%     end
end
% -------------------------------------------------------------------------
% step 3: option panel
% -------------------------------------------------------------------------
if isfield(this.Handles,'PNLoption')
    this.DefaultPos.RADIOoptionbottomoffset_singleNew=this.DefaultPos.heightDynamicPnl+this.DefaultPos.buttomoffsetDynamicPnl-80;
    this.DefaultPos.RADIOoptionbottomoffset_multipleNew=this.DefaultPos.heightDynamicPnl+this.DefaultPos.buttomoffsetDynamicPnl-110;
    this.DefaultPos.RADIOoptionbottomoffset_singleINSERT=this.DefaultPos.heightDynamicPnl+this.DefaultPos.buttomoffsetDynamicPnl-140;
    set(this.Handles.PNLoption,'Position',[this.DefaultPos.leftoffsetDynamicPnl ...
                this.DefaultPos.buttomoffsetDynamicPnl ...
                this.DefaultPos.widthDynamicPnl ...
                this.DefaultPos.heightDynamicPnl]);
    set(this.Handles.RADIOsingleNEW,'Position',[this.DefaultPos.RADIOoptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_singleNew ...
                    this.DefaultPos.RADIOoptionwidth ...
                    this.DefaultPos.heightradio] ...
        );
    set(this.Handles.EDTsingleNEW,'Position',[this.DefaultPos.EDToptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_singleNew-2 ...
                    this.DefaultPos.EDToptionwidth ...
                    this.DefaultPos.heightedt] ...
        );
    set(this.Handles.RADIOmultipleNEW,'Position',[this.DefaultPos.RADIOoptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_multipleNew ...
                    this.DefaultPos.RADIOoptionwidth ...
                    this.DefaultPos.heightradio] ...
        );
    set(this.Handles.COMBmultipleNEW,'Position',[this.DefaultPos.EDToptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_multipleNew ...
                    this.DefaultPos.EDToptionwidth ...
                    this.DefaultPos.heighttxt] ...
        );
    set(this.Handles.TXTmultipleNEW,'Position',...
                    [this.DefaultPos.EDToptionleftoffset+this.DefaultPos.EDToptionwidth+5 ... %35
                    this.DefaultPos.RADIOoptionbottomoffset_multipleNew-4 ...
                    this.DefaultPos.TXToptionmultiplewidth ...
                    this.DefaultPos.heighttxt] ...
        );
    set(this.Handles.EDTmultipleNEW,'Position',...
                    [this.DefaultPos.EDToptionleftoffset+this.DefaultPos.EDToptionwidth+...
                    5+this.DefaultPos.TXToptionmultiplewidth+this.DefaultPos.separation ... %40 jgo
                    this.DefaultPos.RADIOoptionbottomoffset_multipleNew-2 ...
                    this.DefaultPos.EDToptionmultiplewidth ...
                    this.DefaultPos.heightedt] ...
        );
    set(this.Handles.RADIOsingleINSERT,'Position',[this.DefaultPos.RADIOoptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_singleINSERT ...
                    this.DefaultPos.RADIOoptionwidth ...
                    this.DefaultPos.heightradio] ...
        );
    set(this.Handles.COMBsingleINSERT,'Position',[this.DefaultPos.EDToptionleftoffset ...
                    this.DefaultPos.RADIOoptionbottomoffset_singleINSERT ...
                    this.DefaultPos.EDToptionwidth ...
                    this.DefaultPos.heighttxt] ...
        );
    set(this.Handles.BTNRefresh,'Position',[this.DefaultPos.EDToptionleftoffset+...
                this.DefaultPos.EDToptionwidth+7 ... %35
                this.DefaultPos.RADIOoptionbottomoffset_singleINSERT-5 ...
                90 ...
                this.DefaultPos.heightbtn] ...
        );
end

function status = localOpenFile(h,pathname,fileName,fileExtension)

status = false;
if ~isempty(fileExtension) && strcmpi(fileExtension,'.xls')
    % excel
    bar=waitbar(20/100,getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:ValidatingExcelSpreadsheet')));
    % -------------------------------------------------------------------------
    % get information from the file
    % -------------------------------------------------------------------------
    try
        [FileInfo,h.Handles.exceldlg.IOData.DES] = ...
            xlsfinfo(fullfile(pathname,[fileName fileExtension]));
    catch %#ok<CTCH>
        errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:InvalidExcelWorkbook')),...
                        getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
        if ishandle(bar)            
            delete(bar)
        end
        set(h.Handles.EDTbrowser,'String','');
        return;
    end
    if ishandle(bar)
       waitbar(80/100,bar);
    end
    % -------------------------------------------------------------------------
    % check if the file is valid and get sheet number
    % -------------------------------------------------------------------------
    if isempty(FileInfo)
        errordlg(getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:InvalidExcelWorkbook')),...
                        getString(message('MATLAB:tsguis:ImportWizard:ImportWizard:TimeSeriesTools')),'modal');
        set(h.Handles.EDTbrowser,'String','');
        return
    end
    if ishandle(bar)
         delete(bar)
    end
elseif ~isempty(fileExtension) && any(strcmpi(fileExtension,{'.csv','.txt','.dat'}))
     h.Handles.exceldlg.IOData.DES = '';
end
status = true;