function [hThis] = brush(hMode)
% Constructor for the brush mode accessor

%   Copyright 2007-2009 The MathWorks, Inc.

% Syntax: graphics.brush(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:graphics:brush:InvalidConstructor'));
end
if ~strcmpi(hMode.Name,'Exploration.Brushing')
    error(message('MATLAB:graphics:brush:InvalidConstructor'));
end
if ~isempty(hMode.ModeStateData.accessor) && ...
        ishandle(hMode.ModeStateData.accessor)
    error(message('MATLAB:graphics:brush:AccessorExists'));
end
% Constructor
hThis = graphics.brush;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));