function plotdoneevent(parent,h)
% This internal helper function may change in a future release.

%PLOTDONEEVENT Send a plot event that a plot is finished
%    PLOTDONEEVENT(AX,H) sends plot event that objects H have been
%    added to axes AX.

%   Copyright 1984-2010 The MathWorks, Inc.

plotmgr = graph2dhelper('getplotmanager','-peek');
if ishandle(plotmgr)
  evdata = graphics.plotevent(plotmgr,'PlotFunctionDone');
  if ~isempty(parent)
      set(evdata,'ObjectsCreated',h,'Figure',ancestor(parent(1),'figure'));
  else
      set(evdata,'ObjectsCreated',h,'Figure',[]);
  end
  send(plotmgr,'PlotFunctionDone',evdata);
end
