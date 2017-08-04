function gStruct = serializeBrushDataStruct(~,varargin)
% This undocumented function may be removed in a future release.

% Serialize the data properties of a scattergroup so that data editing
% operations such as removing brushed data can be undone.

% Copyright 2013 The MathWorks, Inc.

% Serialize XData,YData and ZData
gStruct = datamanager.serializeBrushDataStruct(varargin{:});

if nargin<=1 || isempty(varargin{1}) % Initialize serialized struct
    fnames = [fieldnames(gStruct); {'Sizedata';'Cdata'}];
    gStruct  = repmat(cell2struct(cell(length(fnames),1),fnames,1),[0 1]);
else
    % Serialize CData, SizeData 
    gStruct.Sizedata = get(varargin{1},'SizeData');
    gStruct.Cdata = get(varargin{1},'CData');
end
