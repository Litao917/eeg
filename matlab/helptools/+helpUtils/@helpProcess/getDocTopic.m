function getDocTopic(hp)
    if usejava('jvm') && ~isempty(hp.fullTopic) && isempty(hp.objectSystemName)
        [path, name] = hp.getPathItem;

        if ~isempty(path)
            hp.docTopic = helpUtils.getDocTopic(path, name, false);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
