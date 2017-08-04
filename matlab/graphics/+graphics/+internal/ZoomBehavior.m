classdef ZoomBehavior < graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013 The MathWorks, Inc.

properties 
    %ENABLE Property is of type 'bool' 
    Enable = true;
    %STYLE Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}' 
    Style =  'both';    
end

properties (Constant)
    %NAME Property is of type 'string' (read only)
    Name = 'Zoom';
end

properties (Transient)
    %SERIALIZE Property is of type 'MATLAB array' 
    Serialize = true;
end

methods
    function set.Style(obj,value)
        % Enumerated DataType = 'StyleChoice enumeration: {'horizontal','vertical','both'}'
        value = validatestring(value,{'horizontal','vertical','both'},'','Style');
        obj.Style = value;
    end
end

methods
    function [ret] = dosupport(~,hTarget)
        % axes
        ret = ishghandle(hTarget,'axes');
    end  
end

end  % classdef

