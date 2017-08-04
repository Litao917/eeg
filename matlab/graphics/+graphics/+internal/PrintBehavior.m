classdef PrintBehavior < graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013 The MathWorks, Inc.

properties (Constant)
    %NAME Property
    Name = 'Print';
end

properties
    PrePrintCallback = [];
    PostPrintCallback = [];
    %WARNONCUSTOMRESIZEFCN Property should be either 'on/off' string
    WarnOnCustomResizeFcn = 'on';
end


properties (Transient)
    %SERIALIZE Property 
    Serialize = true;
end


methods 
    function set.WarnOnCustomResizeFcn(obj,value)
        % values = 'on/off'
        validatestring(value,{'on','off'},'','WarnOnCustomResizeFcn');
        obj.WarnOnCustomResizeFcn = value;
    end

end   % set and get functions 

methods
    function ret = dosupport(~,hTarget)
        % only allowed on Figure and Axes
        ret = ishghandle(hTarget, 'Figure') || ishghandle(hTarget, 'Axes');
    end
end  

end  % classdef

