function [hThis] = rotate3d(hMode)
% Constructor for the rotate3d mode accessor

%   Copyright 2006-2009 The MathWorks, Inc.

% Syntax: graphics.rotate3d(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:graphics:rotate3d:InvalidConstructor'));
end
if ~strcmpi(hMode.Name,'Exploration.Rotate3d')
    error(message('MATLAB:graphics:rotate3d:InvalidConstructor'));
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error(message('MATLAB:graphics:rotate3d:AccessorExists'));
end
% Constructor
hThis = graphics.rotate3d;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));