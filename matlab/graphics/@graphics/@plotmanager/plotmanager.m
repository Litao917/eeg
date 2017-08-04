function h = plotmanager

% Copyright 2011 The MathWorks, Inc.

mlock
persistent pm;

if isempty(pm)
    pm = graphics.plotmanager;
end
h = pm;