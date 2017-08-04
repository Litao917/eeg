function tf = checkReservedNames(names)
%CHECKRESERVEDNAMES Check if variable names conflict with reserved names.

%   Copyright 2012 The MathWorks, Inc.

reservedNames = {'VariableNames' 'RowNames' 'Properties'};
if ischar(names) % names is either a single string ...
    which = strcmp(names, reservedNames);
else             % ... or a cell array of strings
    which = false(size(reservedNames));
    for i = 1:length(names)
        which = which | strcmp(names{i}, reservedNames);
    end
end

tf = any(which);
if (nargout == 0) && tf
    which = find(which,1);
    error(message('MATLAB:table:ReservedNameConflict', reservedNames{which}));
end

