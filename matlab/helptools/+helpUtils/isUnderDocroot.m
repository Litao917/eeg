function underDocroot = isUnderDocroot(file)
% HELPUTILS.ISUNDERDOCROOT - checks whether a file is under the current
% docroot.

% Copyright 2010 The MathWorks, Inc.
if isempty(file)
    underDocroot = false;
else
    unlocalizedDocroot = regexprep(docroot,'[\\/]help[\\/]ja_JP[\\/]?$','/help','once');
    docrootParts = regexp(unlocalizedDocroot, '[\\/]', 'split');
    docrootParts = regexptranslate('escape', docrootParts);
    docrootCheck = sprintf('%s[\\\\/]', docrootParts{:});
    docrootRegexp = ['^(?:(\w{2,}:)+///?)?' docrootCheck '?'];
    underDocroot = ~isempty(regexp(file,docrootRegexp,getCaseArg,'once'));
end
end

function caseArg = getCaseArg
    if ispc
        caseArg = 'ignorecase';
    else
        caseArg = 'matchcase';
    end
end
