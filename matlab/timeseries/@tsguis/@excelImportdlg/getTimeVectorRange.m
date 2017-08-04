function time=getTimeVectorRange(h,starttime,endtime)
% GETTIMEVECTORRANGE returns the valid time vector between starttime and
% endtime

% The return value will be the indices of the valid time values in the
% range or empty if not found. 'starttime' and 'endtime' are strings.

% Author: Rong Chen 
% Copyright 2005-2012 The MathWorks, Inc.

% get active sheet
tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));

% check time vector is a column or a row
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is a column
    % get the available column headings into a cell array
    time=[];
    % get their numeric values and sort them
    first=str2double(starttime);
    last=str2double(endtime);
    if isnan(first) || isnan(last)
        return
    end
    if first>last
        tmp=first;
        first=last;
        last=tmp;
    end
    % get the whole column for search
    timeValue = tmpSheet(1:size(tmpSheet,1),get(h.Handles.COMBtimeIndex,'Value'));
    % search the column for the first time point within the range
    for i=1:size(tmpSheet,1)
        tmpTime=timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(1)=i;
                break;
            end
        end
    end
    % search the column for the last time point within the range
    for i=size(tmpSheet,1):-1:1
        tmpTime=timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(2)=i;
                break;
            end
        end
    end
    time=sort(time);
else
    % the time vector is stored in a row
    % get the available row headings into a cell array
    time=[];
    % get their numeric values and sort them
    first=str2double(starttime);
    last=str2double(endtime);
    if isnan(first) || isnan(last)
        return
    end
    if first>last
        tmp=first;
        first=last;
        last=tmp;
    end
    % get the whole row for search
    timeValue = tmpSheet(get(h.Handles.COMBtimeIndex,'Value'),1:size(tmpSheet,2));
    % search the column for the first time point within the range
    for i=1:size(tmpSheet,2)
        tmpTime=timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(1)=i;
                break;
            end
        end
    end
    % search the column for the last time point within the range
    for i=size(tmpSheet,2):-1:1
        tmpTime=timeValue{i};
        if isnumeric(tmpTime) && ~isnan(tmpTime)
            if tmpTime>=first && tmpTime<=last
                time(2)=i;
                break;
            end
        end
    end
    time=sort(time);
end
