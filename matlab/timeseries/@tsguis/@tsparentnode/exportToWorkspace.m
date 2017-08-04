function exportToWorkspace(this,nodes,varargin)
%Export the model contained in this node to workspace.
%nodes is a cell array of nodes whos data need to be exported to the
%workspace.

% Copyright 2005-2012 The MathWorks, Inc.

%% export this object to workspace
List = evalin('base','who;');

for k = 1:length(nodes)
    node = nodes{k};
    if isa(node,'tsguis.tsnode')
        thisName0 = node.Timeseries.Name;
        ts = timeseries(node.Timeseries.copy);
    else
        thisName0 = node.Tscollection.Name;
        tsh = node.Tscollection.copy;
        tsh.getTimeContainer.ReadOnly = 'on';
        ts = tscollection;
        ts.objH = tsh;
    end
    thisName = genvarname(thisName0);

    if ~strcmp(thisName,thisName0)
        warning(message('MATLAB:tsgtspnodeexportToWorkspace:InvalidObjectName', thisName));
    end

    if ~isempty(strmatch(thisName,List,'exact'))
        ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsparentnode:AVariableAlreadyExists',thisName)),...
            getString(message('MATLAB:timeseries:tsguis:tsparentnode:DuplicatedVariableDetected')), ...
            getString(message('MATLAB:timeseries:tsguis:tsparentnode:Overwrite')), ...
            getString(message('MATLAB:timeseries:tsguis:tsparentnode:Abort')), ...
            getString(message('MATLAB:timeseries:tsguis:tsparentnode:Overwrite')));
        switch ButtonName
            case getString(message('MATLAB:timeseries:tsguis:tsparentnode:Overwrite'))
                assignin('base',thisName,ts);
            case getString(message('MATLAB:timeseries:tsguis:tsparentnode:Abort'))
                return
        end
    else
        %ts = this.SimModelhandle.copy;
        assignin('base',thisName,ts);
    end
end

if ~isempty(nodes)
    msgbox(getString(message('MATLAB:timeseries:tsguis:tsparentnode:ObjectsHaveBeenExportedToTheBaseWorkspace')), ...
        getString(message('MATLAB:timeseries:tsguis:tsparentnode:TimeSeriesTools')), ...
        'modal');
end