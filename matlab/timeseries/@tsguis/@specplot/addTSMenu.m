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
        'Label',getString(message('MATLAB:timeseries:tsguis:specplot:SelectData')),'Tag','selectrule',...
        'Callback',@(es,ed) openselectdlg(this),varargin{:});
    case 'merge'
        % Show input signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
        'Label',getString(message('MATLAB:timeseries:tsguis:specplot:ResampleData')),'Tag','merge',...
        'Callback',@(es,ed) tsguis.mergedlg(this));   
    case 'removemissingdata'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:specplot:RemoveMissingData')),'Tag','removemissingdata',...
            'Callback',{@localPreproc this 4});
    case 'detrend'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:specplot:Detrend')),'Tag','detrend',...
            'Callback',{@localPreproc this 1});
    case 'filter'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:specplot:Filter')),'Tag','filter',...
            'Callback',{@localPreproc this 2});
     case 'interpolate'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
            'Label',getString(message('MATLAB:timeseries:tsguis:specplot:Interpolate')),'Tag','interpolate',...
            'Callback',{@localPreproc this 3});
    case {'remove','delete','keep','newevent'}
        this.addlisteners(handle.listener(this,this.findprop('Responses'),'PropertyPostSet',...
            {@localSyncSelectionMenus this menuType}));
end

%--------------------------------------------------------------------------
function localSyncSelectionMenus(eventSrc, eventData, h, menutype)

%% Listener callback which installs context menus for selected curves on
%% each wave. Note that this listener must be managed at the top level
%% (i.e., can't just be at the view level) since the menu callback needs
%% access to both the data and the view handles 
for k=1:length(h.Responses)
    h.Responses(k).View.addMenu(h,menutype);
end


%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);

