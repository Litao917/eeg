function mRoot = addTSMenu(this,menuType,varargin)
%ADDSIMMENU  Install @timeplot-specific menus.

%  Author(s):
%  Copyright 1986-2011 The MathWorks, Inc.

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
    return
end

switch menuType
    case 'selectrule'
        % Show input signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:SelectData')),'Tag','selectrule',...
            'Callback',@(es,ed) openselectdlg(this),varargin{:});
    case 'merge'
        % Show input signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:ResampleData')),'Tag','merge',...
            'Callback',@(es,ed) tsguis.mergedlg(this));
    case 'shift'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:SynchronizeData')),'Tag','shift',...
            'Callback',@(es,ed) openshiftdlg(this));
    case 'removemissingdata'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:RemoveMissingData')),'Tag','removemissingdata',...
            'Callback',{@localPreproc this 4});
    case 'detrend'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:Detrend')),'Tag','detrend',...
            'Callback',{@localPreproc this 1});
    case 'filter'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:Filter')),'Tag','filter',...
            'Callback',{@localPreproc this 2});
     case 'interpolate'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:Interpolate')),'Tag','interpolate',...
            'Callback',{@localPreproc this 3});   
    case {'remove','delete','newevent','keep'}
        this.addlisteners(handle.listener(this,this.findprop('Waves'),'PropertyPostSet',...
            {@localSyncSelectionMenus this menuType}));
    case 'select'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:SelectionModes')),'Tag','select');
        mDataSelect = uimenu('Parent',mRoot,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:Data')),'Tag','dataselect','Callback',...
            {@localSelectChecked this 'DataSelect'});
        mTimeSelect = uimenu('Parent',mRoot,...
            'Label',getString(message('MATLAB:timeseries:tsguis:timeplot:Time')),'Tag','timeselect','Callback',...
            {@localSelectChecked this 'TimeSelect'});
        this.addlisteners(handle.listener(this,...
            this.findprop('State'),'PropertyPostSet',...
            {@localSetSelectChecked mDataSelect this 'DataSelect'}));
        this.addlisteners(handle.listener(this,...
            this.findprop('State'),'PropertyPostSet',...
            {@localSetSelectChecked mTimeSelect this 'TimeSelect'}));
end

%--------------------------------------------------------------------------
function localSyncSelectionMenus(eventSrc, eventData, h, menutype)

%% Listener callback which installs context menus for selected curves on
%% each wave. Note that this listener must be managed at the top level
%% (i.e., can't just be at the view level) since the menu callback needs
%% access to both the data and the view handles
for k=1:length(h.Waves)
    h.Waves(k).View.addMenu(h,menutype);
end

%--------------------------------------------------------------------------
function localSelectChecked(es,ed,this,mode)

if strcmp(get(es,'Checked'),'off')
    this.setselectmode(mode);
else
    this.setselectmode('None');
end

%--------------------------------------------------------------------------
function localSetSelectChecked(es,ed,mSelect,this,state)

%% Listener callback for plot state change
if strcmpi(this.State,state)
    set(mSelect,'Checked','on')
else
    set(mSelect,'Checked','off')
end

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);



