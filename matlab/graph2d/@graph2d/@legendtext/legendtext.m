function h=legendtext(varargin)
%LEGENDTEXT creates text for a legend object
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.

if (~isempty(varargin))
    h = graph2d.legendtext(varargin{:}); % Calls built-in constructor
else
    h = graph2d.legendtext;
end

% initialize property values -----------------------------

%set up listeners-----------------------------------------

