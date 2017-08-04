function refreshChildrenData(h,varargin)
% if one timeseries member of a collection is changed (time-wise), refresh
% the others. 

% Copyright 2004-2011 The MathWorks, Inc.

if nargin>=2 && isa(varargin{1},'tsdata.dataChangeEvent')
    ed = varargin{1};
else
    return;
end

% Explicitly update the children panels (firing datachange events may
% introduce a circular dependency, as they try to call updatePanel on their
% parents).
if ~isempty(ed)
    localRefreshChildrenData(h,ed);
end

function localRefreshChildrenData(h,ed)
% Refresh timeseries data in the child nodes of tscollectionNode if
% required. Update the data and quality values in each timeseries member to
% match the new Time vector. If a new time sample has been inserted, then
% add NaNs into data vectors of out-of-sync timeseries members.

action = ed.Action;
ind = ed.Index;
if isempty(action)
    return; % Prevent recursion
end

% Initialization
tsList = h.Tscollection.gettimeseriesnames;
tscoll = h.Tscollection;
isTimeseries = isa(ed.Source,'tsdata.timeseries');

if isTimeseries
    % If a transaction is being recordeded for the timeseries,
    % overwrite it to use the tscollection instead.
    recorder = tsguis.recorder;
    if ~isempty(recorder.CurrentTransaction)
        T = recorder.CurrentTransaction;
        T.ObjectsCell = {tscoll};
    end
    % Update the tscollection
    if any(strcmp(tsList,ed.Source.tsValue.Name))
        for k = 1:length(tsList)
            if strcmp(tsList{k},ed.Source.tsValue.Name)
                cacheDataChangeEventsEnabled = tscoll.DataChangeEventsEnabled;
                tscoll.DataChangeEventsEnabled = false;
                % Timeseries actions which don't just result in a reassignment
                % of the tscollection time vector must be handled separately.
                if strcmp(action,'delsample')
                     tscoll.delsamplefromcollection('Index',ind);
                elseif strcmp(action,'resample')
                     tscoll.resample(ed.Source.tsValue.Time);
                elseif strcmp(action,'addsample')
                     if ~isempty(ind)
                          tscoll.addsampletocollection('Time',ed.Source.tsValue.Time(ind));
                     end
                     tscoll.TsValue.(ed.Source.tsValue.Name).Data = ed.Source.tsValue.Data;
                else
                     tscoll.Time = ed.Source.tsValue.Time;
                     tscoll.TimeInfo = ed.Source.tsValue.TimeInfo;
                     tscoll.TsValue.(ed.Source.tsValue.Name) = ed.Source.tsValue;
                end
                tscoll.DataChangeEventsEnabled = cacheDataChangeEventsEnabled;
                tscoll.fireDataChangeEvent;           
            end
        end
    elseif strcmp(action,'Name') % A child has been renamed
        % Find old time series name
        oldNames = setdiff(gettimeseriesnames(tscoll.TsValue),...
            cellfun(@(x) {x.Name},h.getTimeSeries));
        % Modify the tscollection
        if ~isempty(oldNames)
            tscoll.TsValue = settimeseriesnames(tscoll.TsValue,...
                oldNames{1},ed.Source.tsValue.Name);
            tsList = tscoll.gettimeseriesnames;
        end
    end  
end

% Refresh all the sibling nodes
for k = 1:length(tsList)
    thists = h.getTimeSeries(tsList{k});
    cacheDataChangeEventsEnabled = thists.DataChangeEventsEnabled;
    thists.DataChangeEventsEnabled = false;
    thists.TsValue = tscoll.TsValue.(tsList{k});
    thists.DataChangeEventsEnabled = cacheDataChangeEventsEnabled;
    thists.fireDataChangeEvent;
end
