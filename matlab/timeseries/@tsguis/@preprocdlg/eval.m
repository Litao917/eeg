function T = eval(h,evalfcn)

% Copyright 2004-2011 The MathWorks, Inc.

import javax.swing.*; 

T = [];

%% Get recorder handle
recorder = tsguis.recorder;

%% Find the selected time series and column after finishing editing
celleditor = h.Handles.tsTable.getCellEditor;
if ~isempty(celleditor)
    awtinvoke(celleditor,'stopCellEditing()');
    drawnow expose
end
tableData = cell(h.Handles.tsTable.getModel.getData);
if isempty(tableData) % No timeseries
    return
end
I = ~cellfun('isempty',tableData(:,2)) & cell2mat(tableData(:,1));
fullpathSelected = tableData(I,3);
colSelected = tableData(I,4);
if isempty(fullpathSelected)
    return
end

%% Create transaction
T = tsguis.transaction;

%% Parse the cols column
cols = cell(length(fullpathSelected),1);
errorincol = '';
nonuniform = false;
tsList = cell(length(fullpathSelected),1);
for k=1:length(fullpathSelected)
    try
        cols{k} = eval(colSelected{k},'[]');
    end
    tsList(k) = h.ViewNode.getRoot.getts(fullpathSelected{k});
    ts = tsList{k};
    
    if isempty(cols{k}) || any(floor(cols{k})<1) || max(cols{k})>size(ts.Data,2) || ...
            ~isequal(floor(unique(cols{k})),cols{k})
        errordlg(getString(message('MATLAB:timeseries:tsguis:preprocdlg:InvalidColumnsEnteredInRow0numberinteger', k)), ...
            getString(message('MATLAB:timeseries:tsguis:preprocdlg:TimeSeriesTools')),'modal');
        return
    end
    if isnan(ts.TimeInfo.Increment)
        nonuniform = true;
    end
end
if ~isempty(errorincol)
    errordlg(getString(message('MATLAB:timeseries:tsguis:preprocdlg:CannotParseColumnsDefinedForTimeSeries', errorincol)), ...
        getString(message('MATLAB:timeseries:tsguis:preprocdlg:TimeSeriesTools')),'modal');
    return
end
if nonuniform && strcmp(evalfcn,'filt')  && ...
        (strcmp(h.Filter,'firstord') || strcmp(h.Filter,'ideal'))
    ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:preprocdlg:OneOrMoreSelectedTimeSeries')), ...
                       getString(message('MATLAB:timeseries:tsguis:preprocdlg:TimeSeriesTools')), ...
                       getString(message('MATLAB:timeseries:tsguis:preprocdlg:Continue')), ...
                       getString(message('MATLAB:timeseries:tsguis:preprocdlg:Abort')), ....
                       getString(message('MATLAB:timeseries:tsguis:preprocdlg:Continue')));
   drawnow % Prevents thread deadlock
   if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:preprocdlg:Abort')))
       return
   end
end

%% Process each time series in turn
for k=1:length(fullpathSelected)   
    T.ObjectsCell = {T.ObjectsCell{:}, tsList{k}};
    feval(evalfcn,h,tsList{k},cols{k},T);    
end


