function remove(h,ts,colind,T)
%interp
%
% Copyright 1986-2011 The MathWorks, Inc.


%% Recorder initialization
recorder = tsguis.recorder;

%% Remove blank rows
if length(colind)>1 && strcmp(h.Rowor,'off')
   Irowexcl = all(isnan(ts.Data(:,colind))')';
   if strcmp(recorder.Recording,'on')
       T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:RemovingRows'))]);
       T.addbuffer(['Irowexcl = all(isnan(', genvarname(ts.Name), '.Data(:,[' ...
           num2str(colind) ']))'')'';'],ts);        
   end
elseif length(colind)>1 && strcmp(h.Rowor,'on')
   Irowexcl = any(isnan(ts.Data(:,colind))')';
   if strcmp(recorder.Recording,'on')
       T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:RemovingRows'))]);
       T.addbuffer(['Irowexcl = any(isnan(', genvarname(ts.Name), '.Data(:,[' ...
           num2str(colind) ']))'')'';'],ts);        
   end      
else
   Irowexcl = isnan(ts.Data(:,colind));
   if strcmp(recorder.Recording,'on')
       T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:preprocdlg:RemovingRows'))]);
       T.addbuffer(['Irowexcl = isnan(', genvarname(ts.Name), '.Data(:,[' ...
           num2str(colind) ']));'],ts);        
   end        
end
ts.delsample('Value',ts.Time(Irowexcl));
%ts.init(ts.Data(~Irowexcl,:),ts.Time(~Irowexcl));
if strcmp(recorder.Recording,'on')
    T.addbuffer([ts.Name ' = delsample(' genvarname(ts.Name) ',''Index'',find(Irowexcl));'])
end        

