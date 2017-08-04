function schema
%SCHEMA defines the ANNOTATIONLAYER schema
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc.  

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'annotationlayer' , ...
		 pkgHG.findclass('axes'));

pl = schema.prop(h, 'PropertyChangedListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
    
