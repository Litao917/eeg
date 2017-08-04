function schema
% Defines properties for @viewnode parent class .
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
pparent = findpackage('tsexplorer');
c = schema.class(findpackage('tsguis'),'viewnode',findclass(pparent,'node'));

% Public properties
schema.prop(c,'Tree','handle');
schema.prop(c,'AxisCanvas','MATLAB array');
schema.prop(c,'DropAdaptor','MATLAB array');
schema.prop(c,'TableListener','MATLAB array');
schema.prop(c,'Figure','MATLAB array');
schema.prop(c,'Plot','MATLAB array');
schema.prop(c,'DropTarget','MATLAB array');
% FigureVisbility and NodeVisbility are broken out into structure fields
% so that they can be efficiently de-activated to avoid ping-pong
p = schema.prop(c,'ViewListeners','MATLAB array');
p.FactoryValue = struct('FigureVisibility',{[]},'NodeVisibility',{[]});

%% Event which fires when a @timeseries is added or removed from the
%% @viewnode
schema.event(c,'tschanged');
