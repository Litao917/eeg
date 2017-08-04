function setArray(this,A)
%SETARRAY  Writes array value.

%   Copyright 1986-2004 The MathWorks, Inc.
try
   % Store array
   this.Storage.setArray(A,this.Variable);
catch
   % Write error
   error('Value of variable %s could not be written.',this.Variable.Name)
end
