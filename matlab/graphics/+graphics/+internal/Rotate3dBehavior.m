classdef Rotate3dBehavior < graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013 MathWorks, Inc.

properties 
    %ENABLE Property is of type 'bool' 
    Enable = true;
end

properties (Constant)
    %NAME Property is of type 'string' (read only)
    Name = 'Rotate3D';
end

properties (Transient)
    %SERIALIZE Property is of type 'MATLAB array' 
    Serialize = true;
end


methods
    function [ret] = dosupport(~,hTarget)
        % axes 
        ret = ishghandle(hTarget,'axes');
    end
end  
end  % classdef

