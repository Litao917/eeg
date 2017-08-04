function savtoner( state, fig )
%SAVTONER Modify figure to save printer toner.
%   SAVTONER(STATE,FIG) modifies the color of graphics objects to print
%   them on a white background (thus saving printer toner).  STATE is
%   either 'save' to set up colors for a white background or 'restore'.
%   If the Color property of FIG is 'none', nothing is done.
%
%   SAVTONER(STATE) operates on the current figure.
%
%   SAVTONER will be removed in a future release.
%
%   See also NODITHER, PRINT.

%   When printing your Figure window, it is not usually desirable
%   to draw using the background color of the Figure and Axes. Dark
%   backgrounds look good on screen but tend to over-saturate the
%   output page. SAVTONER will Change the Color, MarkerFaceColor,
%   MarkerEdgeColor, FaceColor, and EdgeColor property values of all
%   objects and the X, Y, and Z Colors of all Axes to black if the
%   Figure and Axes are not already white. SAVTONER will also restore
%   the original colors of the objects with the correct input argument.

%   Copyright 1984-2012 The MathWorks, Inc.

warning(message('MATLAB:savtoner:DeprecatedFunction'));

if (nargin == 0) || ~ischar( state ) ...
        || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
    error(message('MATLAB:savtoner:NeedsMoreInfo'))
elseif (nargin == 1)
    adjustbackground(state);
elseif (nargin == 2)
    adjustbackground(state, fig);
end
