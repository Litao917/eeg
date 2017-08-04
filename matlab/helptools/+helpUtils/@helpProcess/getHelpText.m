function getHelpText(hp)
    if ~isempty(hp.topic)
        hp.getTopicHelpText;
        if ~isempty(hp.helpStr)
            return;
        end
    else
        [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', '-hotlink', hp.command);
    end
end

%   Copyright 2007 The MathWorks, Inc.
