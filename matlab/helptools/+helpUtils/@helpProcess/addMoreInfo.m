function addMoreInfo(hp, infoStr, infoCommand, infoArg)
    infoAction = helpUtils.makeDualCommand(infoCommand, infoArg);
    if hp.wantHyperlinks
        moreInfo = sprintf('\n    %s\n       <a href="matlab:%s">%s</a>\n', infoStr, infoAction, infoAction);
    else
        moreInfo = sprintf('\n    %s\n       %s\n', infoStr, infoAction);
    end
    hp.helpStr = [hp.helpStr moreInfo];
end

%   Copyright 2007 The MathWorks, Inc.
