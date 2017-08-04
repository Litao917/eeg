function paste(this,manager)

% Copyright 2005-2011 The MathWorks, Inc.

%% Paste menu callback


if isa(manager.Root.Tsviewer.Clipboard,'tsguis.tsnode')

    %% Copy the timeseries in the clipboard and give it a name which is unique
    %% in the treeview
    newts = manager.Root.Tsviewer.Clipboard.Timeseries.copy;
    if  ~tsIsSameTime(newts.Time, this.Tscollection.Time)
        return;
    end
    newname = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Copy_of_', manager.Root.Tsviewer.Clipboard.Timeseries.Name));
    k = 2;
    while any(strcmp(newname,get(this.getChildren,{'Label'})))
        newname = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:Copy_Number_Of',k,...
            manager.Root.Tsviewer.Clipboard.Timeseries.Name));
        k = k+1;
    end
    newts.Name = newname;

    %% Create new timeseries node by updating the tscollection object ..
    % (The following method adds time series member to the tscollection and also
    % records the transaction)
    this.addTsCallback(newts);
elseif isa(manager.Root.Tsviewer.Clipboard,'tsguis.tscollectionNode')
    this.getParentNode.paste(manager);
end