function adduimode(hFig,hMode)
% This function is undocumented and will change in a future release

%ADDUIMODE
%   ADDUIMODE(FIG,UIMODE) registeres the given mode with the figure. After
%   being registered, a mode may be accessed in a manner analogous to other
%   already registered modes.

%   Copyright 2006-2007 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);
if ~isa(hMode,'uitools.uimode')
    error(message('MATLAB:adduimode:InvalidMode'));
elseif ~isempty(getMode(hManager,hMode.Name))
    error(message('MATLAB:adduimode:ExistingFigureMode'));
else
    registerMode(hManager,hMode);
end
