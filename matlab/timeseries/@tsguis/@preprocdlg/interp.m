function interp(h,ts,~,T)
%interp
%
% Copyright 1986-2011 The MathWorks, Inc.


%% Recorder initialization
recorder = tsguis.recorder;

%% Interpolate missing data
otherTsPath = h.InterptsPath;
if isempty(otherTsPath) % Auto interp
    ts.resample(ts.Time);    
else % Interp from another time series
    warning('off','MATLAB:linearinter:noextrap')
    otherTsList = h.ViewNode.getRoot.getts(otherTsPath);
    otherTs = otherTsList{1}.copy;
    otherTs.resample(ts.Time);
    I = isnan(ts.Data);
    if any(I(:))
        ts.Data(I(:)) = otherTs.Data(I(:));
    else
        return;
    end
    warning('on','MATLAB:linearinter:noextrap')
end

%% Record action
if strcmp(recorder.Recording,'on')
   T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:InterpolatingMissingData'))]);
   if isempty(otherTsPath)
       T.addbuffer([genvarname(ts.name), ' = resample(', genvarname(ts.Name), ',' genvarname(ts.Name), '.Time);'],ts);
   else
       T.addbuffer(sprintf('%s = resample(%s,%s.Time)',genvarname(otherTsList{1}.Name),genvarname(otherTsList{1}.Name),...
           genvarname(ts.Name)),ts,otherTsList{1});
       T.addbuffer(['I = isnan(' genvarname(ts.Name) '.Data);']);
       T.addbuffer(sprintf('%s.Data(I(:)) = %s.Data(I(:));',genvarname(ts.Name),...
           genvarname(otherTsList{1}.Name)));
   end
end
