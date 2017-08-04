function status = eval(h)

% Copyright 2004-2012 The MathWorks, Inc.

%% Apply button callback

%% At least two time series must be selected
I = [];
status = false;
tsList = {};
for row=1:h.Handles.tsTable.getRowCount
    if h.Handles.tsTable.getValueAt(row-1,1)
        I = [I;row]; %#ok<AGROW>
        tsList = [tsList h.ViewNode.getRoot.getts(h.Handles.tsTable.getValueAt(row-1,0))]; %#ok<AGROW>
    end
end
if length(I)<2
    errordlg(getString(message('MATLAB:timeseries:tsguis:shiftdlg:YouMustSelectAtLeastTwoTimeSeries')),...
        getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeSeriesTools')),'modal')
    return
end

%% The reference row must be selected
if ~ismember(h.Handles.tsTable.refRow+1,I)
   errordlg(getString(message('MATLAB:timeseries:tsguis:shiftdlg:AReferenceTimeSeriesMustBeSelectedForSynchronization')),...
       getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeSeriesTools')),'modal')
   return
end

%% Get recorder/transaction handle
recorder = tsguis.recorder;
T = tsguis.transaction;

%% Finish editing
celleditor = h.Handles.tsTable.getCellEditor;
if ~isempty(celleditor)
    awtinvoke(celleditor,'stopCellEditing()');
    drawnow expose
end

%% TO DO: Deal with abs time (REVISIT)
for k=1:length(I)
    row = I(k);
    if strcmp(h.ViewNode.Plot.Absolutetime,'on')
        try
            thisshift = datenum(char(h.Handles.tsTable.getValueAt(row-1,4)));
        catch %#ok<CTCH>
            errordlg(getString(message('MATLAB:timeseries:tsguis:shiftdlg:InvalidDateStringFormat')),...
                getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeSeriesTools')),'modal')
            return
        end
    else
        thisshift = eval(char(h.Handles.tsTable.getValueAt(row-1,4)),'[]');
    end
    if ~isempty(thisshift)
        tsshift(row) = thisshift; %#ok<AGROW>
    else
        errordlg(getString(message('MATLAB:timeseries:tsguis:shiftdlg:InvalidSyncTimeFor',tsList{row}.Name)), ...
            getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeSeriesTools')), 'modal')
        return
    end
    % Save the shift applied to the anchor time series so that it can be
    % added back
    if row==h.Handles.tsTable.refRow+1
        anchorshiftback = tsshift(row);
    end
end

%% Shift the time series
newtimes = {}; %collect the new time vectors, one for each timeseries being shifted.
%note: we collect the intended new time vectors in a loop before changing
%any for the sake of not corrupting tscollection members, because changing
%one member changes others automatically. Hence the same shift gets applied
%multiple times cause actual shift to be N times the actual (intended)
%shift, where N is the number of tscollection members being synchronized.
localshift = zeros(length(tsList) ,1);
for k=1:length(tsList)     
    % Convert the time shift from the plot units to the local time series
    % units
    T.ObjectsCell = [T.ObjectsCell, tsList(k)];
    if strcmp(h.ViewNode.Plot.Absolutetime,'on')
        localshift(k) = (tsshift(k)-anchorshiftback)*...
            tsunitconv(tsList{row}.TimeInfo.Units,'days');
    else
        localshift(k) = (tsshift(k)-anchorshiftback)*...
            tsunitconv(tsList{k}.TimeInfo.Units,h.ViewNode.Plot.TimeUnits);
    end
    for j=1:length(tsList{k}.Events)
        tsList{k}.Events(j).Time = tsList{k}.Events(j).Time-localshift(k); %#ok<AGROW>
    end
    
    newtimes{k} = tsList{k}.Time-localshift(k);   %#ok<AGROW>
end

%% Check that the shift has not created non-unique times
for k = 1:length(tsList)
    if numel(unique(newtimes{k}))<numel(newtimes{k})
        msg = getString(message('MATLAB:timeseries:tsguis:shiftdlg:LimitedDoublePrecisionError',...
            tsList{k}.Name));
        errordlg(msg,getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeSeriesTools')),'modal')
        return
    end
end

%% Record action
for k = 1:length(tsList)
    if strcmp(recorder.Recording,'on') && abs(tsshift(k))>eps
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:shiftdlg:TimeShift'))]); 
        T.addbuffer(sprintf('%s.Time = %s.Time - %f;',...
            genvarname(tsList{k}.Name),genvarname(tsList{k}.Name),localshift(k)),tsList{k});
        if ~isempty(tsList{k}.Events)
            T.addbuffer(sprintf('evList = %s.Events;',genvarname(tsList{k}.Name)));
            for j=1:length(tsList{k}.Events)
                T.addbuffer(sprintf('evList(%d).Time = evList(%d).Time-%f;',j,j,localshift(k)));
            end
            T.addbuffer(sprintf('%s.Events = evList;',genvarname(tsList{k}.Name)));
        end
    end
end


%% Apply the shifts by changing the times to newtimes
for k = 1:length(tsList)
    tsList{k}.Time = newtimes{k}; %#ok<AGROW>
end

%% Report success
status = true;

%% Store transaction
T.commit;
recorder.pushundo(T);
    