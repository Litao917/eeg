function getTopicHelpText(hp)
    [hp.isOperator, hp.topic] = helpUtils.isOperator(hp.topic, true);

    classInfo = [];
    malformed = false;
    alternateHelpFunction = [];
    
    if hp.isOperator
        hasLocalFunction = false;
    else
        [hp.topic, hasLocalFunction] = helpUtils.fixLocalFunctionCase(hp.topic);

        if ~hasLocalFunction
            [classInfo, hp.fullTopic, malformed] = helpUtils.splitClassInformation(hp.topic, '', false);
            if isempty(classInfo)
                [hp.topic, ~, hp.fullTopic, ~, alternateHelpFunction] = helpUtils.fixFileNameCase(hp.topic, '', hp.fullTopic);
            else
                hp.isMCOSClass = classInfo.isMCOSClass;
                classHelpTopic = hp.topic;
                hp.extractFromClassInfo(classInfo);
                alternateHelpFunction = [];
            end
        end
    end
    
    
    if useSingleSource(hp) && hp.getHelpTextFromDoc(classInfo)
        hp.needsHotlinking = false;
        hp.commandIsHelp = false;
        return;
    end

    if ~isempty(classInfo)
        if classInfo.isAccessible
            [hp.helpStr, hp.needsHotlinking, hp.suppressedImplicit] = classInfo.getHelp(hp.command, classHelpTopic, hp.wantHyperlinks);
        end
        return;
    end

    if malformed
        return;
    end

    if ~isempty(alternateHelpFunction)
        hp.helpStr = helpUtils.callHelpFunction(alternateHelpFunction, hp.fullTopic);
        hp.needsHotlinking = true;
        [~, hp.topic] = fileparts(hp.fullTopic);
        return;
    end
    
    [hp.helpStr, hp.needsHotlinking] = builtin('helpfunc', hp.topic, '-hotlink', hp.command);
    if ~isempty(hp.helpStr) && ~hasLocalFunction
        helpFor = regexpi(hp.helpStr, getString(message('MATLAB:help:HelpForBanner', '(?<topic>[\w\\/.@+]*)')), 'names', 'once');
        if ~isempty(helpFor)
            hp.extractFromClassInfo(helpFor.topic);
        else 
            dirInfos = helpUtils.hashedDirInfo(hp.topic)';
            if isempty(hp.fullTopic)
                for dirInfo = dirInfos
                    hp.fullTopic = helpUtils.extractCaseCorrectedName(dirInfo.path, hp.topic);
                    if ~isempty(hp.fullTopic)
                        hp.topic = helpUtils.minimizePath(hp.fullTopic, true);
                        hp.isDir = true;
                        return;
                    end
                end
            else
                [~, hp.topic] = hp.getPathItem;
                if strcmp(hp.topic, 'handle')
                    hp.isMCOSClass = true;
                elseif ~hp.isDir
                    hp.isDir = ~isempty(dirInfos);
                end
            end
        end
    end
end

function singleSource = useSingleSource(hp)
    singleSource = ~hp.suppressDisplay && usejava('jvm');
    if singleSource && strncmpi(get(0,'language'),'en',2)
        s = Settings;
        singleSource = s.matlab.desktop.help.SingleSource;
    end
end
%   Copyright 2007 The MathWorks, Inc.