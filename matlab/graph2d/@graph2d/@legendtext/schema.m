function schema
%SCHEMA defines the LEGENDTEXT schema
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'legendtext' , pkgHG.findclass('text'));
    
