function serializeDatatips(hThis)
% Serializes the information located in the data cursors associated with
% the mode and stores them in application data of the figure.

%   Copyright 2007-2012 The MathWorks, Inc.

% Get a handle to the data tips:
hDatatips = hThis.DataCursors;

if isempty(hDatatips)
    return;
end

% For each data tip, create a structure containing the necessary
% information for reconstruction.
CursorPropsToSave = {'Target', 'DataIndex', 'Position', ...
    'InterpolationFactor', 'TargetPoint'};

Cursors = get(hDatatips(:), {'DataCursorHandle'});
PropValues = get([Cursors{:}], CursorPropsToSave);
dataStruct = cell2struct(PropValues, CursorPropsToSave, 2);
setappdata(hThis.Figure,'DatatipInformation',dataStruct);

TipPropsToSave = {'Orientation', 'OrientationMode'};
PropValues = get(hDatatips(:), TipPropsToSave);
dataStruct = cell2struct(PropValues, TipPropsToSave, 2);
setappdata(hThis.Figure,'DatatipTipProperties',dataStruct);

% Store a handle to the update function of the mode as well.
modeUpdateFcn = hThis.UpdateFcn;
setappdata(hThis.Figure,'DatatipUpdateFcn',modeUpdateFcn);
