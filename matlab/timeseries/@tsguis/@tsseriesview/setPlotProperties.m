function status = setPlotProperties(h,ts)

% Copyright 2006-2012 The MathWorks, Inc.

status = true;

%% Initial wave is abs time vector so start with an absolute time vector
if isempty(h.Plot.waves) && ~isempty(ts{1}.TimeInfo.StartDate)
    h.Plot.StartDate = ts{1}.TimeInfo.StartDate;
    h.Plot.TimeUnits = 'days';
    thisDateFormat = ts{1}.TimeInfo.Format;
    if ~isempty(thisDateFormat) && tsIsDateFormat(thisDateFormat)
        h.Plot.TimeFormat = ts{1}.TimeInfo.Format;
    end
elseif length(h.Plot.waves)>=1 &&  isempty(ts{1}.TimeInfo.StartDate)~= isempty(h.Plot.waves(1).DataSrc.Timeseries.TimeInfo.StartDate)
    errordlg(getString(message('MATLAB:timeseries:tsguis:tsseriesview:YouCannotCombineRelativeAndAbsoluteTimeSeries')),...
       getString(message('MATLAB:timeseries:tsguis:tsseriesview:TimeSeriesTools')),'modal')
    status = false;
    return
% Relative time vector to absolute plot      
elseif strcmp(h.Plot.Absolutetime,'on') && isempty(ts{1}.TimeInfo.StartDate)
    msg = getString(message('MATLAB:timeseries:tsguis:tsseriesview:AttemptToAddARelativeTimeSeries'));
    ButtonName = questdlg(msg, ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:TimeVectorReferenceMismatch')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:ConvertViewToRelativeTime')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Continue')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')));         
    if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')))
        status = false;
        return
    end
    if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:tsseriesview:ConvertViewToRelativeTime')))
        h.Plot.Startdate = '';
    end
elseif strcmp(h.Plot.Absolutetime,'off') && ~isempty(ts{1}.TimeInfo.StartDate)
    msg = getString(message('MATLAB:timeseries:tsguis:tsseriesview:AttemptToAddAnAbsoluteTimeVector'));
    ButtonName = questdlg(msg, ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:TimeVectorReferenceMismatch')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Continue')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')), ...
        getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')));
    if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:tsseriesview:Abort')))
        status = false;
        return
    end
end

%% If this is the first time series to be added sets the units/format in the
%% @timeplot to the current timeseries units/format
if isempty(h.Plot.waves) 
   set(h.Plot,'TimeUnits',ts{1}.TimeInfo.Units,...
       'TimeFormat',ts{1}.TimeInfo.Format)
   h.Plot.AxesGrid.XUnits = h.Plot.TimeUnits;
end