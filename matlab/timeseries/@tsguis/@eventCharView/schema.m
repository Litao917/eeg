function schema
%SCHEMA  Defines properties for @eventCharView class

%   Author(s):  
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class
%superclass = findclass(findpackage('wrfc'), 'view');
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('tsguis'), 'eventCharView', superclass);

% Public attributes
schema.prop(c, 'VLines', 'MATLAB array');    % Handles of vertical lines 
