function [hThis] = zoom(hMode)
% Constructor for the zoom mode accessor

%   Copyright 2002-2009 The MathWorks, Inc.

% Syntax: graphics.zoom(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:graphics:zoom:InvalidConstructor'));
end
if ~strcmpi(hMode.Name,'Exploration.Zoom')
    error(message('MATLAB:graphics:zoom:InvalidConstructor'));
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error(message('MATLAB:graphics:zoom:AccessorExists'));
end
% Constructor
hThis = graphics.zoom;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));