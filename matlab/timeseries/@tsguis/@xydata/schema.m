function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wrfc');
c = schema.class(p, 'xydata',findclass(pparent,'data'));

% Public properties
schema.prop(c, 'XData', 'MATLAB array');
schema.prop(c, 'YData', 'MATLAB array');






