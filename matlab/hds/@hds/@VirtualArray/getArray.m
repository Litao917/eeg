function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 1986-2004 The MathWorks, Inc.
try
   A = this.Storage.getArray(this.Variable);
catch 
   % Read error
   A = [];
end
