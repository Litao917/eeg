function schema
%SCHEMA defines the LEGENDPATCH schema
%
%  See also LEGEND, GRAPH2D.LEGEND, GRAPH2D.LEGENDLINE

%   Copyright 1984-2005 The MathWorks, Inc.

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'legendpatch' , pkgHG.findclass('patch'));

p = schema.prop(h,'PatchHandle','handle');
p = schema.prop(h,'DisplayMarkerSize','NReals'); %should be double

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';

pl = schema.prop(h, 'LegendStyleListener', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';

