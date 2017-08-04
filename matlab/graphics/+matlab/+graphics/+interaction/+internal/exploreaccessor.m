classdef (CaseInsensitiveProperties = true) exploreaccessor < hgsetget 
%matlab.graphics.interaction.internal.exploreaccessor class
%   Copyright 2013 The MathWorks, Inc.

properties (AbortSet, SetObservable, GetObservable)
    % callback
    ButtonDownFilter = [];
    ActionPreCallback = [];
    ActionPostCallback = [];
    Enable % takes values 'on/off'
end

properties (AbortSet, SetObservable, GetObservable, Hidden)
    ModeHandle = []; % for handle
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    FigureHandle = [];
end


methods  % constructor block
    function [hThis] = exploreaccessor(hMode)
    % Constructor for the mode accessor
    if ~isvalid(hMode) || ~isa(hMode,'matlab.uitools.internal.uimode')
     error(message('MATLAB:graphics:exploreaccessor:InvalidConstructor'));
    end
    set(hThis,'ModeHandle',hMode);
    hMode.ModeStateData.accessor = hThis;
    end  % exploreaccessor
    
end  % constructor block

methods 
    function value = get.ButtonDownFilter(obj)
        value = localGetFromMode(obj,obj.ButtonDownFilter,'ButtonDownFilter');
    end
    function set.ButtonDownFilter(obj,value)
        % no MATLAB callback checks yet'
        obj.ButtonDownFilter = localSetToMode(obj,value,'ButtonDownFilter');
    end

    function value = get.ActionPreCallback(obj)
        value = localGetFromMode(obj,obj.ActionPreCallback,'ActionPreCallback');
    end
    function set.ActionPreCallback(obj,value)
        % no MATLAB callback checks yet'
        obj.ActionPreCallback = localSetToMode(obj,value,'ActionPreCallback');
    end

    function value = get.ActionPostCallback(obj)
        value = localGetFromMode(obj,obj.ActionPostCallback,'ActionPostCallback');
    end
    function set.ActionPostCallback(obj,value)
        % no MATLAB callback checks yet'
        obj.ActionPostCallback = localSetToMode(obj,value,'ActionPostCallback');
    end

    function value = get.Enable(obj)
        value = localGetEnable(obj,obj.Enable);
    end
    function set.Enable(obj,value)
        % DataType = 'on/off'
        validatestring(value,{'on','off'},'','Enable');
        obj.Enable = localSetEnable(obj,value);
    end

    function value = get.FigureHandle(obj)
        value = localGetFromMode(obj,obj.FigureHandle,'FigureHandle');
    end

end   % set and get functions 
end  % classdef

function newValue = localSetToMode(hThis,valueProposed,propName)
% Set the mode property
    try
        set(hThis.ModeHandle,propName,valueProposed);
    catch ex
        rethrow(ex);
    end
newValue = valueProposed;
end  % localSetToMode


%------------------------------------------------------------------------%
function valueToCaller = localGetFromMode(hThis,valueStored,propName)
% Get the mode property
    try
        valueToCaller = get(hThis.ModeHandle,propName);
    catch ex
        rethrow(ex);
    end
end  % localGetFromMode


%------------------------------------------------------------------------%
function newValue = localSetEnable(hThis,valueProposed)
% Activate or deactivate the mode
hMode = hThis.ModeHandle;
try
    if strcmpi(valueProposed,'on')
        activateuimode(hThis.FigureHandle,hMode.Name);
    else
        activateuimode(hThis.FigureHandle,'');
    end
catch ex
    rethrow(ex);
end
newValue = valueProposed;
end  % localSetEnable


%------------------------------------------------------------------------%
function valueToCaller = localGetEnable(hThis,valueStored)
% Find out if the current mode is running
hMode = hThis.ModeHandle;
res = isactiveuimode(hThis.FigureHandle,hMode.Name);
if res
    valueToCaller = 'on';
else
    valueToCaller = 'off';
end
end  % localGetEnable
