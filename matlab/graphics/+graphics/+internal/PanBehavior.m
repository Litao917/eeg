classdef PanBehavior < graphics.internal.HGBehavior
% This undocumented class may be removed in a future release.

% Copyright 2013 The MathWorks, Inc.

properties 
    %ENABLE Property is of type 'bool' 
    Enable = true;
    %STYLE Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}' 
    Style = 'both';
end

properties (SetAccess=protected, Transient)
    %NAME Property is of type 'string' (read only)
    Name = 'Pan';
end

properties (Transient)
    %SERIALIZE Property is of type 'MATLAB array' 
    Serialize = true;
end

events 
    BeginDrag
    EndDrag
end  % events

methods  
    function set.Style(obj,value)
        % Enumerated DataType = 'StyleChoice enumeration: {'horizontal','vertical','both'}'
        value = validatestring(value,{'horizontal','vertical','both'},'','Style');
        obj.Style = value;
    end

end   % set function 

methods (Hidden) 
    function [ret] = dosupport(~,hTarget)
        % axes
        ret = ishghandle(hTarget,'axes');
    end

    function sendBeginDragEvent(hThis)
        % notify the listeners of BeginDrag event
        notify(hThis,'BeginDrag');
    end
    
    function sendEndDragEvent(hThis)
         % notify the listeners of EndDrag event
        notify(hThis,'EndDrag');
    end
end

end  % classdef

