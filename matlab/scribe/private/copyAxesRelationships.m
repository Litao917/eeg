% Copyright 2012 The MathWorks, Inc.

function serializedStruct = copyAxesRelationships(serializedStruct, obj)
    % Capture axes relationships
    parentax = ancestor(obj, 'axes');
    if get(parentax,'Title') == obj
        serializedStruct.specialChild = 'Title';
    elseif get(parentax,'XLabel') == obj
        serializedStruct.specialChild = 'XLabel';
    elseif get(parentax,'YLabel') == obj
        serializedStruct.specialChild = 'YLabel';
    elseif get(parentax,'ZLabel') == obj
        serializedStruct.specialChild = 'ZLabel';
    end
end
