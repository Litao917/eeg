function dispmsg = getTimeStr(h,timeInfo)

% Copyright 2005-2012 The MathWorks, Inc.

%% Generates a string describing the time vector

%% Create the current time vector string
if ~isempty(timeInfo.StartDate)
    if tsIsDateFormat(timeInfo.Format)
        try
            startstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units),timeInfo.Format);
            endstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.End*tsunitconv('days',...
                 timeInfo.Units),timeInfo.Format);
        catch
             startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units));
             endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
                timeInfo.Units));
        end
    else
        startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
        endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
    end
    dispmsg = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CurrentTimeTo',startstr,endstr));
else
    startTimeStr = sprintf('%.4g', timeInfo.Start);
    endTimeStr = sprintf('%.4g', timeInfo.End);
    if isnan(timeInfo.Increment)
        dispmsg = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CurrentTimeNonuniform',...
            startTimeStr, endTimeStr, timeInfo.Units));
    else
        dispmsg = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CurrentTimeUniform',...
            startTimeStr, endTimeStr,timeInfo.Units));
    end
end