function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wrfc');
c = schema.class(p, 'corrdata',findclass(pparent,'data'));

% Public properties
schema.prop(c, 'CData', 'MATLAB array');
schema.prop(c, 'Lags', 'MATLAB array');






