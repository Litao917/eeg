function schema
% Defines properties for @tsnode class.
%
%   Author(s): James G. Owen
%   Copyright 2004-2012 The MathWorks, Inc.


%% Register class (subclass)
pparent = findpackage('tsexplorer');
c = schema.class(findpackage('tsguis'), 'tsparentnode', ...
    findclass(pparent,'node'));

%The parent node keeps information on its child types.
p = schema.prop(c,'legalChildren','MATLAB array');
p.FactoryValue = {'timeseries','tscollection','tsdata.timeseries','tsdata.tscollection'};
p.Description = getString(message('MATLAB:timeseries:tsguis:tsparentnode:ListAllValid'));
p.AccessFlags.PublicSet = 'off';