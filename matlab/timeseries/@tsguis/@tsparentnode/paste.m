function paste(this,manager)

% Copyright 2004-2012 The MathWorks, Inc.

%% Paste menu callback


if isa(manager.Root.Tsviewer.Clipboard,'tsguis.tsnode')

    %% Copy the timeseries in the clipboard and give it a name which is unique
    %% in the treeview
    newts = manager.Root.Tsviewer.Clipboard.Timeseries.copy;
    newname = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CopyOf', ...
        manager.Root.Tsviewer.Clipboard.Timeseries.Name));
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if isa(G(n),'tsguis.tsnode') && strcmp(newname,G(n).Label)
            newname = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CopyNumberOf', ...
                k,manager.Root.Tsviewer.Clipboard.Timeseries.Name));
            k = k+1;
        end
    end
    newts.Name = newname;
    %% Create new timeseries node
    this.createChild(newts,newname);
elseif isa(manager.Root.Tsviewer.Clipboard,'tsguis.tscollectionNode')
    %% Copy the tscollection in the clipboard and give it a name which is unique
    %% in the treeview
    newtsc = manager.Root.Tsviewer.Clipboard.Tscollection.copy;
    newname = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CopyOf', ...
        manager.Root.Tsviewer.Clipboard.Tscollection.Name));
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if isa(G(n),'tsguis.tscollectionNode') && strcmp(newname,G(n).Label)
            newname = getString(message('MATLAB:timeseries:tsguis:tsparentnode:CopyNumberOf', ...
                k, manager.Root.Tsviewer.Clipboard.Tscollection.Name));
            k = k+1;
        end
    end

    newtsc.Name = newname;
    %% Create new timeseries node
    this.createChild(newtsc,newname);
end