function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 1986-2012 The MathWorks, Inc.

menu = getDefaultPopupSchema(this,manager,varargin{:});

%% Create menus
menuRemoveMissing = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:RemoveMissingData')));
menuDetrend = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:Detrend')));
menuFilter = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:Filter')));
menuInterpolate = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:Interpolate')));
menuResample = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:Resample')));
menuTimeshift = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:SynchronizeData')));
menuSelect = com.mathworks.mwswing.MJMenuItem(getString(message('MATLAB:timeseries:tsguis:tsseriesview:DataSelection')));

%% Add them
menu.addSeparator;
menu.add(menuRemoveMissing);
menu.add(menuDetrend);
menu.add(menuFilter);
menu.add(menuInterpolate);
menu.addSeparator;
menu.add(menuResample);
menu.add(menuTimeshift);
menu.add(menuSelect);
% menu.addSeparator;
% menu.add(menuExpression);

%% Assign menu callbacks
set(handle(menuTimeshift,'callbackproperties'),'ActionPerformedCallback',...
    {@localOpenshiftdlg  this manager})
set(handle(menuRemoveMissing,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 4})
set(handle(menuDetrend,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 1})
set(handle(menuFilter,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 2})
set(handle(menuInterpolate,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 3})
set(handle(menuResample,'callbackproperties'),'ActionPerformedCallback',...
    {@localMerge this})
set(handle(menuSelect,'callbackproperties'),'ActionPerformedCallback',...
    {@localOpenselectdlg  this manager})


%--------------------------------------------------------------------------
function localPreproc(~,~,this,Ind)

RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);

function localOpenshiftdlg(~,~,h,manager)

openshiftdlg(h,manager)

function localMerge(~,~,h)

tsguis.mergedlg(h);

function localOpenselectdlg(~,~,h,manager)

openselectdlg(h,manager)


