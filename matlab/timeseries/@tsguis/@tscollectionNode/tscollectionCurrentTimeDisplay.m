function tscollectionCurrentTimeDisplay(h,varargin)
%% Method which builds/populates the tscollection current time (text info)
%% on the viewcontainer panel. 

%   Author(s): Rajiv Singh
%   Copyright 2005-2011 The MathWorks, Inc.

import javax.swing.*;

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

tinfo = h.Tscollection.TimeInfo;
if isempty(tinfo)
     h.Handles.currentTimeInfo = uicontrol('parent',h.Handles.pnlTimeInfo,...
        'style','text','String',{},'Units','Characters','pos',[0.01 0.02 0.99 0.98]/10,...
        'HorizontalAlignment','Left','vis','off');
    return
end
if isempty(tinfo.StartDate)
    tinfoStartStr = sprintf('%0.3g', tinfo.Start);
    tinfoEndStr = sprintf('%0.3g', tinfo.End);
    unitStr = tinfo.getUnitsDisplayStr();
    if isnan(tinfo.Increment)
        str_tinfo = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:NonuniformUnitsWithSamples',...
            tinfoStartStr,tinfoEndStr,unitStr,tinfo.Length));
    else
        str_tinfo = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:UniformUnitsWithSamples',...
            tinfoStartStr,tinfoEndStr,unitStr,tinfo.Length));
    end
else
    startTime = tinfo.Start*tsunitconv('days',tinfo.Units)+datenum(tinfo.StartDate);
    endTime = tinfo.End*tsunitconv('days',tinfo.Units)+datenum(tinfo.StartDate);
    if ~isempty(tinfo.Format) && tsIsDateFormat(tinfo.Format)
        startTimeStr = datestr(startTime,tinfo.Format);
        endTimeStr = datestr(endTime,tinfo.Format);
    else
        startTimeStr = datestr(startTime);
        endTimeStr = datestr(endTime);
    end
    
    if isnan(tinfo.Increment)
        str_tinfo = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:NonuniformWithSamples',...
            startTimeStr,endTimeStr,tinfo.Length));
    else
        str_tinfo = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:UniformWithSamples',...
            startTimeStr,endTimeStr,tinfo.Length));
    end
end
strcell = {[getString(message('MATLAB:timeseries:tsguis:tscollectionNode:CurrentTimeInformation')), ' ', str_tinfo]};

if ~isfield(h.Handles,'currentTimeInfo') || isempty(h.Handles.currentTimeInfo)
    h.Handles.currentTimeInfo = uicontrol('parent',h.Handles.pnlTimeInfo,...
        'style','text','String',strcell,'Units','Characters','pos',[0.01 0.02 0.99 0.98]/10,...
        'HorizontalAlignment','Left','vis','off');
else
    set(h.Handles.currentTimeInfo,'String',strcell,'vis','on');
end

