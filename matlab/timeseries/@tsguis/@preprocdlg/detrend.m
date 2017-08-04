function detrend(h,ts,colinds,T)
%detrend
%
% Copyright 1986-2011 The MathWorks, Inc.

%% Recorder initialization
recorder = tsguis.recorder;

%% Detrending
ts.detrend(h.Detrendtype,colinds);
if strcmp(recorder.Recording,'on')
    T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:DetrendingTimeSeries'))]);
    T.addbuffer([genvarname(ts.Name), '= detrend(', genvarname(ts.Name), ',''' h.Detrendtype ...
           ''',[' num2str(colinds), ']);'],ts);
end        
