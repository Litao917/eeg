function hdfPanelConstruct(this, hdftree, hImportPanel, title)
%HDFPANELCONSTRUCT Construct an HDFPanel.
%   This function should be used by all classes that derive from
%   the hdfPanel class.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   HDFTREE: the hdfTree which contains this panel.
%   HIMPORTPANEL: The HG parent of this panel.
%   TITLE: The title of this panel.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Store important handles
    this.fileTree = hdftree;
    this.title    = title;

    if isempty(hdftree.mainPanel)
        % Initialize several shared panel components.
        handles = makePanelFrame(this, hdftree, hImportPanel);
        hdftree.wsvarnamehandle  = handles.wsvarnamehandle;
        hdftree.matlabCmdhandle      = handles.matlabCmdhandle;
        hdftree.hImportMetadata = handles.hImportMetadata;

        hdftree.mainPanel  = this.mainpanel;
        hdftree.mainLayout = this.mainLayout;
        hdftree.subsetPanelContainer   = this.subsetPanelContainer;
    else
        % Obtain references to shared panel components.
        this.mainpanel  = hdftree.mainPanel;
        this.mainLayout = hdftree.mainLayout;
        this.subsetPanelContainer   = hdftree.subsetPanelContainer;
    end

    this.subsetPanel = uipanel('Parent',this.subsetPanelContainer,...
        'visible', 'off');

end

function handles = makePanelFrame(this, hdftree, hImportPanel)
    % The panel frame need only be constructed once.
    this.mainPanel = uipanel('parent',hImportPanel,...
        'FontWeight', 'bold',...
        'FontSize', 1 + get(0, 'defaultUipanelFontSize'),...
        'Visible', 'off',...
        'Title', '',...
        'units', 'normalized',...
        'position', [0 0 1 1]);

    this.mainLayout = uiflowcontainer('v0', 'Parent',this.mainPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    this.subsetPanelContainer = uipanel('Parent',this.mainLayout,...
        'BorderType', 'etchedin',...
        'Title', getString(message('MATLAB:imagesci:hdftool:subsetSelectionParameters')));

    [importPanel, handles] = this.createImportGroup(this.mainLayout);

end
