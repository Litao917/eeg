classdef DataCursorBehavior < graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013 The MathWorks, Inc.

properties (Constant)
    %NAME Property (read only)
    Name = 'DataCursor';
end

properties
    StartDragFcn = [];
    EndDragFcn = [];
    UpdateFcn = [];
    CreateFcn = [];
    StartCreateFcn = [];
    UpdateDataCursorFcn = [];
    MoveDataCursorFcn = [];
    %CREATENEWDATATIP Property takes true/false 
    CreateNewDatatip = false;
    %ENABLE Property takes true/false
    Enable = true;
end


properties (Transient)
    %SERIALIZE Property 
    Serialize = true;
end


methods 
    function [ret] = dosupport(~,hTarget)
        % axes or axes children
        ret = ~isempty(ancestor(hTarget,'Axes'));
    end
end 

end  % classdef

