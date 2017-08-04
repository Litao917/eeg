function varStruc = getSelectedVarInfo(h)

% GETSELECTEDVARINFO  Retrieves the selected variable structure 

% Copyright 2005-2007 The MathWorks, Inc.


thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
% Use the variable name to find the h.variables since the table may
% have been sorted
if ~isempty(thisSelection)
    ind = strcmp({h.variables.varname},...
        char(h.javahandle.getValueAt(thisSelection(1),0)));
    varStruc = h.variables(ind);
end

