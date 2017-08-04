function filt(h,ts,colinds,T)
%FEVAL

% Copyright 2004-2011 The MathWorks, Inc.

%% Initialize recorder
recorder = tsguis.recorder;

%% No-op for vacuous time series
if ts.TimeInfo.length<2
    return
end

%% Filtering
% TO DO: What if the first or last point contains a NaN?
% Discrete transfer fcn
if strcmp(h.Filter,'transfer')
    ts.filter(h.Bcoeffs,h.Acoeffs,colinds);
    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:FilteringTimeSeries'))]);
        T.addbuffer([ts.Name ' = filter(' genvarname(ts.Name) ',[' num2str(h.Bcoeffs) '],[' ...
             num2str(h.Acoeffs) '],[' num2str(colinds) ']);'],ts);
    end
% Ideal continuous
elseif strcmp(h.Filter,'ideal')
    unitfactor = tsunitconv(ts.TimeInfo.Units,h.ViewNode.getPlotTimeProp('TimeUnits'));
    ts.idealfilter(unitfactor*h.range,h.Band,colinds);
    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:FilteringTimeSeries'))]);
        T.addbuffer([ts.Name '= idealfilter(' genvarname(ts.Name) ',[' ...
                num2str(h.Range*unitfactor) '],''' h.Band ''',[' num2str(colinds) ']);'],ts);
    end 
% First order
elseif strcmp(h.Filter,'firstord')
    unitfactor = tsunitconv(ts.TimeInfo.Units,h.ViewNode.getPlotTimeProp('TimeUnits'));
    % Non-uniformly sampled
    if isnan(ts.TimeInfo.Increment)
           Ts = (ts.TimeInfo.End-ts.TimeInfo.Start)/ts.TimeInfo.length;
           ts.resample(linspace(ts.TimeInfo.Start,ts.TimeInfo.End,ts.TimeInfo.length));
           ts.filter(Ts/(h.Timeconst*unitfactor+Ts),...
               [1 -h.Timeconst*unitfactor/(h.Timeconst*unitfactor+Ts)],colinds);
           if strcmp(recorder.Recording,'on')
               T.addbuffer(['Ts = (' genvarname(ts.Name) '.TimeInfo.End-' genvarname(ts.Name) '.TimeInfo.Start)/' ...
                   genvarname(ts.Name) '.TimeInfo.length;'],ts);
               T.addbuffer([genvarname(ts.Name) ' = resample(' genvarname(ts.Name) ',linspace(' genvarname(ts.Name) '.TimeInfo.Start,' ...
                   genvarname(ts.Name) '.TimeInfo.End,' genvarname(ts.Name) '.TimeInfo.length));']);
               T.addbuffer([genvarname(ts.Name) ' = filter(' genvarname(ts.Name) ',Ts/('  num2str(h.Timeconst*unitfactor) '+Ts),[1 -' ...
                   num2str(h.Timeconst*unitfactor) '/(' num2str(h.TimeConst*unitfactor) '+Ts)],[' ...
                   num2str(colinds) ']);']);
           end   
    % Uniformly sampled
    else 
        try
            ts.filter(ts.TimeInfo.Increment/(h.Timeconst*unitfactor+ts.TimeInfo.Increment),...
               [1 -h.Timeconst*unitfactor/(h.Timeconst*unitfactor+ts.TimeInfo.Increment)],colinds);
        catch me
            err1 = me.message;
            if strcmp(err1.identifier,'timeseries:filter:allnans')  
                msg = getString(message('MATLAB:timeseries:tsguis:preprocdlg:FilteringOperationFailedNaNs'));
            else
                msg = getString(message('MATLAB:timeseries:tsguis:preprocdlg:FilteringOperationFailedErrorWas', err1.message));
            end
            errordlg(msg, getString(message('MATLAB:timeseries:tsguis:preprocdlg:TimeSeriesTools')),'modal')
            return
        end
        if strcmp(recorder.Recording,'on')
            T.addbuffer([genvarname(ts.Name) ' = filter(' genvarname(ts.Name) ',' genvarname(ts.Name) ...
                '.TimeInfo.Increment/(' num2str(h.Timeconst*unitfactor) ...
                '+' genvarname(ts.Name) '.TimeInfo.Increment),[1 -' num2str(h.Timeconst*unitfactor) ...
                '/(' num2str(h.Timeconst*unitfactor) ...
                '+' genvarname(ts.Name) '.TimeInfo.Increment)],[' num2str(colinds) ']);'],ts);
        end
    end
end
    