function schema
%SCHEMA  Defines properties for @eventCharView class

%   Author(s):  
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('tsguis'), 'tsCharLineView');
c = schema.class(findpackage('tsguis'), 'histMeanView', superclass);

% Public attributes
