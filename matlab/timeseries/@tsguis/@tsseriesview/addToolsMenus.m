function addToolsMenus(h,f)

% Copyright 2005-2012 The MathWorks, Inc.

%% Adds tools menus for this plot type. Overloading this method lets
%% non-timeplots exclude irrelevant Tools menus

%% Get the tools menu
mtools = findobj(allchild(f),'type','uimenu','Tag','figMenuTools');

%% Add 'Select data...' menu
uimenu('Parent',mtools,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:SelectData')),'Callback',...
    @(es,ed) openselectdlg(h),'Separator','on');
%% Add 'Merge/resample...' menu
uimenu('Parent',mtools,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:ResampleData')),'Callback',...
    @(es,ed) tsguis.mergedlg(h));
%% Add Process data...' menu
mpreproc = uimenu('Parent',mtools,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:ProcessData')));
uimenu('Parent',mpreproc,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:RemoveMissingData')),'Callback',...
    {@localPreproc h 4});
uimenu('Parent',mpreproc,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:Detrend')),'Callback',...
    {@localPreproc h 1});
uimenu('Parent',mpreproc,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:Filter')),'Callback',...
    {@localPreproc h 2});
uimenu('Parent',mpreproc,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:Interpolate')),'Callback',...
    {@localPreproc h 3});

%% Add 'Time shift...' menu
uimenu('Parent',mtools,'Label',getString(message('MATLAB:timeseries:tsguis:tsseriesview:SynchronizeData')),'Callback',...
    @(es,ed) openshiftdlg(h));

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);
