function schema
% Defines properties for @viewcontainer class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
pparent = findpackage('tsexplorer');
c = schema.class(findpackage('tsguis'), 'viewcontainer',findclass(pparent,'node'));

% Public properties
schema.prop(c,'PlotCache','MATLAB array');
schema.prop(c,'TstableListener','MATLAB array');
schema.prop(c,'ChildClass','string');

% viewcontentschange event signals a chnage in the viewcontainer contents
schema.event(c,'viewcontentschange');
