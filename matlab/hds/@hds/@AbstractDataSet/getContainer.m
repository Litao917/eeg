function C = getContainer(this,Variable)
%GETCONTAINER  Accesses data container for a given variable or link.

%   Copyright 1986-2005 The MathWorks, Inc.
if isa(Variable,'char')
   Variable = findvar(hds.VariableManager,Variable);
end
C = find(this.Data_,'Variable',Variable);
if isempty(C) && ~isempty(this.Children_)
   C = find(this.Children_,'Alias',Variable);
end
if isempty(C)
   error(sprintf('Unknown variable %s',Variable.Name))
end
