function nodither(state, fig)
%NODITHER Modify figure to avoid dithered lines.
%   NODITHER(STATE,FIG) modifies the color of graphics objects to
%   black or white, whichever best contrasts the figure and axis
%   colors.  STATE is either 'save' to set up colors for black
%   background or 'restore'.
%
%   NODITHER(STATE) operates on the current figure.
%
%   NODITHER will be removed in a future release.
%
%   See also SAVTONER, BWCONTR, PRINT

%   Copyright 1984-2012 The MathWorks, Inc.

warning(message('MATLAB:nodither:DeprecatedFunction'));

if (nargin == 0) || ~ischar( state ) ...
        || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
    error(message('MATLAB:nodither:invalidFirstArgument'))
elseif (nargin == 1)
    contrastcolors(state);
elseif (nargin == 2)
    contrastcolors(state, fig);
end

