function schema
% Defines properties for @uitspanel subclass of uipanel.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.

%% Package and class info
hg = findpackage('hg');
c = schema.class(findpackage('tsguis'),'uitspanel',...
    hg.findclass('uipanel'));
p = schema.prop(c,'Plot','MATLAB array');
p = schema.prop(c,'jpanel','com.mathworks.mwswing.MJPanel');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'PropPanel','com.mathworks.toolbox.timeseries.UITsPanelPropPanel');
p.AccessFlags.Serialize = 'off';
schema.prop(c,'Name','string');




