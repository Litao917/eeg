function tstable_childnameupdate(h,varargin)
%Callback that updates the name of the tsparent members in response to
%a child tsnode/tscollection name change event.

%   Copyright 2005-2012 The MathWorks, Inc.

if isempty(h.Handles) || isempty(h.Handles.PNLtsTable) || ...
        ~ishghandle(h.Handles.PNLtsTable)
    return % No panel
end

Names = get(h.getChildren,{'Label'});
Data = cell(h.Handles.tsTable.getModel.getData);
Data(:,1) = Names;
headings = {getString(message('MATLAB:timeseries:tsguis:tsparentnode:Name')), ...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:Type')), ...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:TimeVector')), ...
    getString(message('MATLAB:timeseries:tsguis:tsparentnode:Description'))};
h.Handles.tsTable.getModel.setDataVector(Data,headings,h.Handles.tsTable);

