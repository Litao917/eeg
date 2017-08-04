function gStruct = serializeBrushDataStruct(~,varargin) 
% This undocumented function may be removed in a future release.

% Serialize the data properties of a @sereis so that data editing
% operations such as removing brushed data can be undone.

% Copyright 2013 The MathWorks, Inc.

% Serialize XData,YData and ZData
gStruct = datamanager.serializeBrushDataStruct(varargin{:});
