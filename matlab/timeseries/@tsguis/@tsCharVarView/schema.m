function schema
%SCHEMA  Defines properties for @TimeFinalValueView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('tsguis'), 'tsCharLineView');
c = schema.class(findpackage('tsguis'), 'tsCharVarView', superclass);

% Public attributes
schema.prop(c, 'VLines', 'MATLAB array');    % Handles of vertical lines 
