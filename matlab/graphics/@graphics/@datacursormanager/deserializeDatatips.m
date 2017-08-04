function deserializeDatatips(hThis)
% Deserializes the information located in the application data of the
% figure and creates datatips corresponding to the information found there.

%   Copyright 2007-2012 The MathWorks, Inc.

hFig = hThis.Figure;
if ~isappdata(hFig,'DatatipInformation')
    return;
end

% Get the update function of the mode
modeUpdateFcn = getappdata(hFig,'DatatipUpdateFcn');
if ~isempty(modeUpdateFcn)
    if iscell(modeUpdateFcn)
        hFun = modeUpdateFcn{1};
    else
        hFun = modeUpdateFcn;
    end
    % The update function can either be a string or a function handle at
    % this point, if it is a function handle, make sure we can find the
    % file.
    if isa(hFun,'function_handle')
        funInfo = functions(hFun);
        funFile = funInfo.file;
        funName = funInfo.function;
        if isempty(funFile) || (~isempty(funFile) && ~exist(funFile,'file'))
            warning(message('MATLAB:graphics:deserializeDatatips', funName));
        else
            hThis.UpdateFcn = modeUpdateFcn;
        end
    else
        hThis.UpdateFcn = modeUpdateFcn;
    end
end
rmappdata(hFig,'DatatipUpdateFcn');

dataStruct = getappdata(hFig,'DatatipInformation');
rmappdata(hFig,'DatatipInformation');

if isappdata(hFig, 'DatatipTipProperties')
    tipPropStruct = getappdata(hFig,'DatatipTipProperties');
    rmappdata(hFig,'DatatipTipProperties');
else
    tipPropStruct = repmat(struct(), size(dataStruct));
end

for i = 1:numel(dataStruct);
    tip = hThis.createDatatip(dataStruct(i).Target,dataStruct(i));
    set(tip, tipPropStruct(i));
end
