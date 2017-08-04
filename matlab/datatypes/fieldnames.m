%FIELDNAMES Get structure field names or object properties.
%   NAMES = FIELDNAMES(S) returns a cell array of strings containing 
%   the names of the fields in structure S.
%
%   NAMES = FIELDNAMES(Obj) returns a cell array of strings containing 
%   the names of the public properties of Obj. MATLAB objects can overload
%   FIELDNAMES and define their own behavior.
%
%   NAMES = FIELDNAMES(Obj,'-full') returns a cell array of strings 
%   containing the name, type, attributes, and inheritance of the
%   properties of Obj. Only supported for COM or Java objects.
%   
%   See also ISFIELD, GETFIELD, SETFIELD, ORDERFIELDS, RMFIELD.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.

