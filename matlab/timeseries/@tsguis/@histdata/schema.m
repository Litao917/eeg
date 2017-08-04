function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2006 The MathWorks, Inc.


% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'histdata',findclass(p,'xydata'));

% Public properties
schema.prop(c, 'Watermarky', 'MATLAB array'); 
schema.prop(c, 'Watermarkx', 'MATLAB array');
schema.prop(c, 'Focus', 'MATLAB array'); % Focus (preferred range)






