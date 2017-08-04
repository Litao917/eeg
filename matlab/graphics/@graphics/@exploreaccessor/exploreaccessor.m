function [hThis] = exploreaccessor(hMode)
% Constructor for the mode accessor

%   Copyright 2006 The MathWorks, Inc.

% Syntax: graphics.exploreaccessor(mode,name)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:graphics:exploreaccessor:InvalidConstructor'));
end

% Constructor
hThis = graphics.exploreaccessor;

set(hThis,'ModeHandle',hMode);
hMode.ModeStateData.accessor = hThis;