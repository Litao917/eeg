function A = getArray(this,Variable)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(Container,Variable)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
f = this.FileName;
if isempty(f)
   A = [];
else
   v = Variable.Name;
   try
      S = load(f,v);
      A = S.(v);
   catch
      A = [];
      warning(sprintf(...
         'Data file %s cannot be found or does not contain variable %s.',f,v))
   end
end