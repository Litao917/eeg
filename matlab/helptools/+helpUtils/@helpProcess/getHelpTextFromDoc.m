function found = getHelpTextFromDoc(hp, classInfo)
    found = false;
    
    if ~isDocHelpType(classInfo)
        return;
    end
    
    docTopic = hp.docTopic;
    if isempty(docTopic)
        docTopic = hp.topic;
    end
    
    funcType = com.mathworks.helpsearch.reference.RefEntityType.FUNCTION;
    helpTopic = com.mathworks.mlwidgets.help.HelpTopic(docTopic, funcType);
    fromDoc = char(helpTopic.getHelpText);
    if ~isempty(fromDoc)
        hp.helpStr = char(helpTopic.getHelpText);
        hp.docTopic = char(helpTopic.getDocCommandArgument);
        found = true;
    end
end

function useDoc = isDocHelpType(classInfo)
    useDoc = false;
    if isempty(classInfo) || classInfo.isMethod
        useDoc = true;
    end
end