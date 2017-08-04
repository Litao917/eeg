function [fileName, foundTarget] = extractFile(dirInfo, targetName)
    [fileName, foundTarget] = extractField(dirInfo, 'm', targetName);
    if ~foundTarget
        [fileName, foundTarget] = extractField(dirInfo, 'p', targetName);
    end
end

function [fileName, foundTarget] = extractField(dirInfo, field, targetName)
    fileIndex = strcmpi(dirInfo.(field), [targetName '.' field]);
    foundTarget = any(fileIndex);
    if foundTarget
        fileName = dirInfo.(field){fileIndex}(1:end-2);
    else
        fileName = '';
    end
end

%   Copyright 2008 The MathWorks, Inc.
