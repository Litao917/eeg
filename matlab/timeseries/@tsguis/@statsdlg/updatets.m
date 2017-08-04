function updatets(h,varargin)

% Copyright 2004-2012 The MathWorks, Inc.

%% Identify any node being deleted
skipnode = [];
if nargin>=2 && isa(varargin{1},'tsexplorer.tstreeevent') && ...
        strcmp(get(varargin{1},'Action'),'remove')
    skipnode = get(varargin{1},'Node');
end
    
h.SrcNode.updatePathCache;
[pathnames, tsnames] = h.Srcnode.dir;
tableData =  cell(0,3);
row = 1;
for k=1:length(tsnames)
    tsnodes = h.Srcnode.search(pathnames{k});
    if length(tsnodes)==1 && (isempty(skipnode) || ~any(find(skipnode,'-depth',inf)==tsnodes))
        tableData(row,:) = {tsnames{k}, pathnames{k}, ...
            sprintf('%d',size(tsnodes.Timeseries.Data,2))};
        row = row+1;
    end 
end
h.Handles.tsTable.getModel.setDataVector(tableData,...
        {getString(message('MATLAB:timeseries:tsguis:statsdlg:TimeSeries')), ...
        getString(message('MATLAB:timeseries:tsguis:statsdlg:Path')), ...
        getString(message('MATLAB:timeseries:tsguis:statsdlg:NumberOfColumns'))},...
        h.Handles.tsTable);
    
selRows = h.Handles.tsTable.getSelectedRows;
if length(selRows)==0
    awtinvoke(h.Handles.tsTable,'setRowSelectionInterval(II)',0,0);
end