function node = createTimeSeriesNode(h,ts)

% Copyright 2005-2011 The MathWorks, Inc.

%% Method which figures out wether to add the time series to the Simulink
%% parent node or the Timeseries parent, based on its class
node = ts.createTstoolNode(h.TSnode);    
if ~isempty(node)
    node = h.TSnode.addNode(node);
end



