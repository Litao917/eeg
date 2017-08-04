% Copyright 2012 The MathWorks, Inc.

function serializedStruct = pasteAxesRelationships(serializedStruct, obj)
    % Restore axes relationships
    if isfield(serializedStruct, 'specialChild')
        ax = ancestor(obj, 'axes');
        set(ax, serializedStruct.specialChild, obj);
    end
end
