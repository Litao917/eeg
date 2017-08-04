function tstable_childnameupdate(h,varargin)
%Callback that updates the name of the tscollection members in response to
%a child tsnode name change event.

%   Copyright 2005-2011 The MathWorks, Inc.

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

Names = get(h.getChildren,{'Label'});
Data = cell(h.Handles.membersTable.getModel.getData);
Data(:,1) = Names;
headings = {getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Name')), ...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:DataCols')), ...
    getString(message('MATLAB:timeseries:tsguis:tscollectionNode:DataUnits'))};
h.Handles.membersTable.getModel.setDataVector(Data,headings,h.Handles.membersTable);



