classdef LinkBehavior < graphics.internal.HGBehavior
%This is an undocumented class and may be removed in future
%
% Copyright 2013 MathWorks, Inc.


properties
    %DATASOURCE Property takes any character 
    DataSource = '';
    DataSourceFcn = [];
    LinkBrushFcn = [];
    BrushFcn = [];
    UserData = [];
    %ENABLE Property takes true/false
    Enable = true;
    %SERIALIZE Property takes true/false
    Serialize = false;
end

properties (Constant)
    %NAME Property is read only
    Name = 'Linked';
end


methods
    function ret = dosupport(~,hTarget)
        ret = ishghandle(hTarget);
    end
end

end  % classdef

