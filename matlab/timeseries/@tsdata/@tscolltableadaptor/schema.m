function schema

%   Copyright 2005-2006 The MathWorks, Inc.

% Register class (subclass)
p = findpackage('tsdata');
c = schema.class(p,'tscolltableadaptor',findclass(p, 'tstableadaptor'));
