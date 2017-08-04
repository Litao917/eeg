function addEvent(h,e)

% Copyright 2006-2011 The MathWorks, Inc.

%% Currently events must have a unique name in the time series
if any(strcmp(e.Name,get(h.Timeseries.Events,{'Name'})))
    errordlg(getString(message('MATLAB:timeseries:tsguis:tsnode:NamesMustBeUnique')),...
        getString(message('MATLAB:timeseries:tsguis:tsnode:TimeSeriesTools')),'modal')
    return
end

%% Add an event to the internal time series
h.Timeseries.addevent(e);

%% Create transaction
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Record action
if strcmp(recorder.Recording,'on')
    T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:tsnode:AddNewEvent'))]);
    T.addbuffer(['e = tsdata.event(''' e.Name ''',' sprintf('%f',e.Time) ,');']);
    T.addbuffer(['e.Units = ''' e.Units ''';']);
    if ~isempty(e.StartDate)
         T.addbuffer(['e.StartDate = ''' e.StartDate ''';']);
    end
    T.addbuffer([genvarname(h.Timeseries.Name) ' =  addevent(' ...
        genvarname(h.Timeseries.Name) ',e);'],h.Timeseries);
end

% add the timeseries to the transaction object
T.ObjectsCell = [T.ObjectsCell, {h.Timeseries}];

%% Store transaction
T.commit;
recorder.pushundo(T);