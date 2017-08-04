function importTsCallback(this,varargin)
%add members to tscollection 

%   Copyright 2005-2011 The MathWorks, Inc.

% Add from import dialog

tmp = tsguis.tsImportdlg('Title',getString(message('MATLAB:timeseries:tsguis:tscollectionNode:ImportTimeSeriesFromWorkspace')),...
           'HelpFile','d_import_fr_workspace',...
           'TypesAllowed',{'timeseries'});
tmp.open;
if isempty(tmp.OutputValue)
    return
else
    names = fieldnames(tmp.OutputValue);
    for i=1:length(names)
        ts = tmp.OutputValue.(names{i});
        this.addTsCallback(ts,names{i});
    end
end
