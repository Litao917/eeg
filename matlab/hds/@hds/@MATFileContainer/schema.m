function schema
% Defines properties for @MATFileContainer class
% (implements @ArrayContainer interface)

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('hds');
c = schema.class(p,'MATFileContainer',findclass(p,'ArrayContainer'));

% Public properties
schema.prop(c,'FileName','string');  % MAT file name

