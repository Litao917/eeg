function [hThis] = pan(hMode)
% Constructor for the pan mode accessor

%   Copyright 2006-2009 The MathWorks, Inc.

% Syntax: graphics.pan(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:graphics:pan:InvalidConstructor'));
end
if ~strcmpi(hMode.Name,'Exploration.Pan')
    error(message('MATLAB:graphics:pan:InvalidConstructor'));
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error(message('MATLAB:graphics:pan:AccessorExists'));
end
% Constructor
hThis = graphics.pan;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));