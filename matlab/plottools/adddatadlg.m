function result = adddatadlg (ax, fig)
% This undocumented function may be removed in a future release.

% ADDDATADLG Show a dialog that asks the user to add a data trace to an axes.

% Copyright 2003-2007 The MathWorks, Inc.

error(nargchk(2,2,nargin))
figpeer = javaGetFigureFrame(fig);
jax = figpeer.getAxisComponent;    % a Java method
javaMethodEDT('showInstance','com.mathworks.page.plottool.AddDataPanel',java(handle(ax)),jax);
