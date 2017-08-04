function errorDocCallback(topic, fileName, lineNumber)
    if ~isempty(help(topic))
        helpPopup(topic);
    else
        functionName = topic;
        split = regexp(functionName, filemarker, 'split', 'once');
        hasFileMarker = numel(split) > 1;
        if hasFileMarker
            functionName = split{1};
            if ~isempty(help(functionName))
                helpPopup(functionName);
                return;
            end
        end
        className = regexp(functionName, '.*?(?=/[\w.]*$|\.\w+$)', 'match', 'once');
        if ~isempty(meta.class.fromName(className)) && ~isempty(help(className))
            helpPopup(className);
        else
            editTopic = topic;
            if ~hasFileMarker && isempty(className)
                editTopic = [topic, filemarker, topic];
            end
            editSucceeded = false;
            try %#ok<TRYNC>
                editSucceeded = edit(editTopic);                
            end
            if ~editSucceeded
                if nargin == 3 && ~isempty(fileName)
                    opentoline(fileName, lineNumber, 0);
                else
                    helpdlg(getString(message('MATLAB:helpUtils:errorDocCallback:Undocumented', topic)), getString(message('MATLAB:helpUtils:errorDocCallback:UndocumentedTitle')));
                end
            end
        end
    end
end

%   Copyright 2010 The MathWorks, Inc.
