function update(h)

% Copyright 2004-2012 The MathWorks, Inc.

%% Maintain listeners to the current view member time series to keep the
%% table up to date
import com.mathworks.toolbox.timeseries.*;

%% Find the time series in the view 
if ~isempty(h.ViewNode) && ishandle(h.ViewNode)
    timePlot = h.ViewNode.Plot;
else % Node has been deleted, remove time series listeners
    h.StateListeners.Timeseries = [];
    return
end

%% If the viewNode has just been created there will not yet be a timePlot.
%% In this case open an empty table
%% TO DO: Deal with absolute times
if ~isempty(timePlot) && ishandle(timePlot)
    tsList = timePlot.getTimeSeries;
    
    % Update the datachange listeners
    delete(h.StateListeners.Timeseries)
    h.StateListeners.Timeseries = [];
    for k=1:length(tsList)
        h.StateListeners.Timeseries = [h.StateListeners.Timeseries; ...
            handle.listener(tsList{k},'datachange',{@localEventsUpdate h,tsList{k}})]; 
    end    
    
    % Listeners to keep time units and time formats updated
    if isempty(h.UnitListener)
        h.UnitListener = [handle.listener(timePlot.AxesGrid,'ViewChange',...
            {@localSetTimeUnits h.Handles.LBLunits timePlot});...
                          handle.listener(timePlot,timePlot.findprop('Absolutetime'),...
             'PropertyPostSet',{@localEventsUpdate h})];
            
    end
    localSetTimeUnits([],[],h.Handles.LBLunits,timePlot);
else
    tsList = [];
    set(h.Handles.LBLunits,'String','')
end

%% Reset the time shift/events table
tsPath = {};
for k=length(tsList):-1:1
    tsPath{k} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',tsList{k}));
end
h.Handles.tsTable.setTableData(tsPath);
h.eventsupdate

function localSetTimeUnits(~,~,LBLunits,timePlot)

%% TimePlot unit change callback
if strcmp(timePlot.Absolutetime,'off')
    set(LBLunits,'String', ...
        getString(message('MATLAB:timeseries:tsguis:shiftdlg:PlotTimeUnits',...
            timePlot.TimeUnits)))
else
    set(LBLunits,'String','')
end

function localEventsUpdate(~,~,h,tslistItem)

if nargin>=4
    eventsupdate(h,tslistItem);
else
    eventsupdate(h);
end
 