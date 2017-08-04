function menu = getPopupSchema(this,manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 1986-2012 The MathWorks, Inc.

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuAddPlot = com.mathworks.mwswing.MJMenuItem(...
    getString(message('MATLAB:timeseries:tsguis:viewcontainer:NewPlot')));
menu.add(menuAddPlot);

%% Assign menu callbacks
set(handle(menuAddPlot,'callbackproperties'),'ActionPerformedCallback',...
    {@localAddPlot this manager})

function localAddPlot(~,~,h,manager)

addPlot(get(get(manager,'Root'),'tsViewer'),get(h,'Label'));
