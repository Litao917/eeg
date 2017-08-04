function [b, className] = isClassMFile(fullPath)
    [~, whichComment] = which(fullPath);
    classSplit = regexp(whichComment, '(?<name>\w*)\s*constructor$', 'names', 'once');
    b = ~isempty(classSplit);
    if b
        className = classSplit.name;
    else
        className = '';
    end
