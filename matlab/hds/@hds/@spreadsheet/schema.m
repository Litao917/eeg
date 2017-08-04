function schema
% Defines properties for @spreadsheet class.

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
pk = findpackage('hds');
c = schema.class(pk,'spreadsheet',findclass(pk,'dataset'));
