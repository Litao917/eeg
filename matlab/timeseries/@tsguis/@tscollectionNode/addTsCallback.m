function addTsCallback(this,ts,Name)
%callback to addts actions from right-click popup menu option on the node
%or the "add members" button from the tscollectionNode panel.

% Copyright 2005-2011 The MathWorks, Inc.

if nargin<3
    Name = genvarname(ts.Name);
end

try
    % Record the addts transaction
    T = tsguis.nodetransaction;
    recorder = tsguis.recorder;
    T.ObjectsCell = {ts};
    T.Action = 'added';
    T.ParentNodeHandle = this;

    % Now update the dataobject to add a new member to the
    % collection
    try
        addts(this.Tscollection,ts,ts.name);
    catch me
        if strcmp(me.identifier,'MATLAB:tscollection:localCheckTS:badtime')
            errordlg(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeCollectionVectorsMismatch')),...
                'modal')
        end
        return
    end

    % Record the transaction
    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ' getString(message('MATLAB:timeseries:tsguis:tscollectionNode:AddNewTimeSeriesMemberToTscollection'))]);
        T.addbuffer([genvarname(this.Tscollection.Name), ' = addts( ',...
            genvarname(this.Tscollection.Name),', ',Name,', ''',genvarname(ts.Name),''');'],this.Tscollection);
    end

    % Store transaction
    T.commit;
    recorder.pushundo(T);

catch me
    errordlg(getString(message('MATLAB:timeseries:tsguis:tscollectionNode:AddNewTimeSeriesError', me.message)),...
        getString(message('MATLAB:timeseries:tsguis:tscollectionNode:TimeSeriesTools')),'modal')
end