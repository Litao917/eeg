function whichTopic = safeWhich(topic)
    [~, name, ext] = fileparts(topic);
    if ~isempty(ext)
        whichTopic = which(topic);
        if ~isempty(whichTopic)
            [~, ~, whichExt] = fileparts(whichTopic);
            if ~strcmpi(ext, whichExt)
                whichTopic = '';
            end
        end
    else
        whichTopic = which([topic, '.m']);
        if isempty(whichTopic)
            whichTopic = which(topic);
            [~, whichName] = fileparts(whichTopic);
            if ~strcmpi(name, whichName)
                whichTopic = '';
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
