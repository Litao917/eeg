function addTs(h,ts1,ts2)

%   Copyright 2004-2011 The MathWorks, Inc.

%% Check that the plot is not too large
if size(ts1.Data,2)*size(ts2.Data,2)>144
    errordlg(getString(message('MATLAB:timeseries:tsguis:xyplot:TooManyAxes')),...
        getString(message('MATLAB:timeseries:tsguis:xyplot:TimeSeriesTools')),'modal')
    return
end

%% New time series require the xlimmode to be in auto to ensure that they
%% can be seen
h.AxesGrid.xlimmode = 'auto';
h.AxesGrid.ylimmode = 'auto';

%% Turn off limit manager and listeners
h.Listeners.setEnabled(false);
h.AxesGrid.LimitManager = 'off';

%% Check that the time series are compatible
if size(ts1.Data,1) ~= size(ts2.Data,1)
    msg = getString(message('MATLAB:timeseries:tsguis:xyplot:CannotDisplayDifferingNumberOfSamples',...
        ts1.Name,ts1.timeInfo.Length,ts2.Name,ts2.timeInfo.Length));
    msg = [msg, getString(message('MATLAB:timeseries:tsguis:xyplot:DoYouWantToOpenTheMergeDialog'))];
    ButtonName = questdlg(msg, getString(message('MATLAB:timeseries:tsguis:xyplot:TimeSeriesTools')), ...
                       getString(message('MATLAB:timeseries:tsguis:xyplot:OK')), ...
                       getString(message('MATLAB:timeseries:tsguis:xyplot:Cancel')), ...
                       getString(message('MATLAB:timeseries:tsguis:xyplot:Cancel')));
    if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:xyplot:OK')))    
        tsguis.datamergedlg(h.Parent);
    end
end

%% If there is an existing response remove it
rs = h.Responses;
for k=1:length(rs)
    h.rmresponse(rs(k));
end


%% Create new tssource
src = tsguis.tssource;
set(src,'Timeseries',ts1,'Timeseries2',ts2);

  
%% Size the xyplot to match the size of the time series data vectors
[NewOutputNames,NewInputNames] = src.getrcname;
resize(h,NewOutputNames,NewInputNames)

%% Make sure all new axes have the right behavior
h.setbehavior

%% Overwrite the axesgrid labels to remove the prefixes 'To:' and
%% 'From:'
set(h.axesgrid,'RowLabel',NewOutputNames,'ColumnLabel',NewInputNames)

%% Add the new response
r = h.addresponse(src);
r.datafcn = {@xyresp src r};
set(r,'Name',sprintf('%s vs. %s',ts1.Name,ts2.Name));

%% Add a listener to each @timeseries datachange event which fires the 
%% waveform datachanged event
r.addlisteners(handle.listener(ts1,'datachange', ...
    {@localDataChange r}));
r.addlisteners(handle.listener(ts2,'datachange', ...
    {@localDataChange r}));

%% Add a listener to each timeseries name property of the Plot Data
%% to update the axes labeling
r.addlisteners(handle.listener(ts1,ts1.findprop('Name'),'PropertyPostSet',...
    {@localDataChange r}));
r.addlisteners(handle.listener(ts2,ts2.findprop('Name'),'PropertyPostSet',...
    {@localDataChange r}));

%% Update title
ax = h.AxesGrid.getaxes;
h.axesgrid.Title = getString(message('MATLAB:timeseries:tsguis:xyplot:XYPlot', ...
    ts1.Name,ts2.Name));
h.axesgrid.Xlabel = ts1.Name;

% Restore xlimmode and limit manager
h.Listeners.setEnabled(true);
h.AxesGrid.LimitManager = 'on';

%% Draw
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
h.draw
warning(S);




function localDataChange(eventSrc, eventData,r)

%% @timeseries datachange listener callback
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
r.DataSrc.send('SourceChanged');
%% Update viewnode and viewnodecontainer panels
r.Parent.Parent.send('tschanged')
warning(S);
