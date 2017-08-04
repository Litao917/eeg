function h = lineseries(varargin)
%LINESERIES Line plot helper function
%  This function is an internal helper function for line plots.

%  H = LINESERIES(PARAM1, VALUE1, PARAM2, VALUE2, ...) constructs
%  a lineseries object, applies the specified parameter-value pairs
%  and return the result in H.
%
%  LINESERIES('init') will only register the lineseries class and
%  won't return a lineseries object.
%
%  LINESERIES('event',H) sends a PlotFunctionDone event for objects
%  H and returns.
%
%  See also: PLOT

%   Copyright 1984-2010 The MathWorks, Inc. 

lineseriesmex;
if (nargin > 0) && ischar(varargin{1}) % any string as first arg is special
  if strcmp(varargin{1},'event')
    % adapted code from specgraph/private/plotdoneevent.m
    objs = handle(varargin{2});
    plotmgr = graph2dhelper('getplotmanager','-peek');
    if ~isempty(plotmgr) && ishandle(plotmgr)
      evdata = graphics.plotevent(plotmgr,'PlotFunctionDone');
      set(evdata,'ObjectsCreated',objs,'Figure',ancestor(objs(1),'figure'));
      send(plotmgr,'PlotFunctionDone',evdata);
    end
  end
else
  h = double(graph2d.lineseries(varargin{:}));
end