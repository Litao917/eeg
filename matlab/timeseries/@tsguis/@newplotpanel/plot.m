function plot(h,manager)

%   Author(s): James Owen
%   Copyright 2004-2012 The MathWorks, Inc.

%% Display button callback.

tsList = h.Node.getTimeSeries;
if length(tsList)>10
    ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:newplotpanel:AttemptingToPlotMore',length(tsList))), ...
                       getString(message('MATLAB:timeseries:tsguis:newplotpanel:TimeSeriesTools')), ...
                       getString(message('MATLAB:timeseries:tsguis:newplotpanel:Continue')), ...
                       getString(message('MATLAB:timeseries:tsguis:newplotpanel:Abort')), ...
                       getString(message('MATLAB:timeseries:tsguis:newplotpanel:Abort')));
    if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:newplotpanel:Abort')));
        return
    end
end

%% If the existing view radio button is selected find the view node
%% node
if get(h.Handles.RADIOexist,'Value')>0.5
    ind = get(h.Handles.COMBexistview,'Value');
    availableViews = get(h.Handles.COMBexistview,'String');
    % TO DO: replace tsguis.tsseriesview by its parent class - when
    % implemented
    allViews = setdiff(manager.Root.TsViewer.ViewsNode.find(...
        '-depth',2),manager.Root.TsViewer.ViewsNode.find('-depth',1));
    selectedViewNodePos = ...
        strcmp(availableViews{ind},get(allViews,{'Label'}));
    selectedView = allViews(selectedViewNodePos);
%% If the new view radio button is selected create the @tsseriesview node
else
    % Get new view name
    newplotname = get(h.Handles.EDITnewview,'String');
    if isempty(newplotname)
        errordlg(getString(message('MATLAB:timeseries:tsguis:newplotpanel:YouMustSpecifyANameForTheNewPlot')),...
            getString(message('MATLAB:timeseries:tsguis:newplotpanel:TimeSeriesTools')),'modal')
        return
    end
    
    % Get new view type
    viewnames = get(h.Handles.COMBViewType,'String');
    newviewtype = viewnames{get(h.Handles.COMBViewType,'Value')};
    
    % Create new view
    selectedView = ...
        manager.Root.TsViewer.ViewsNode.getChildren('Label',newviewtype).addplot(...
              manager,newplotname);
end
 
%% Add the @timeseries to the selected @tsseriesview node
if isempty(tsList)
    return
end
selectedView.addTs(tsList);

h.update(manager,[]);