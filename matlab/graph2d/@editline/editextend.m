function aObj = editextend(aObj, varargin)
%EDITLINE/EDITEXTEND End edit for editline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

t = aObj;
tH = get(aObj,'MyHandle');
initVal = get(tH,'LineWidth');
virtualslider('init', tH, .5, initVal, 30, .5, 'set', 'LineWidth');
