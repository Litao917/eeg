function schema
% Defines properties for @dataset class

%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
pk = findpackage('hds');
c = schema.class(pk,'dataset',findclass(pk,'AbstractDataSet'));

% Public properties
p = schema.prop(c,'MetaData','MATLAB array');  % Meta data
p.GetFunction = @localGetMetaData;
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'off';



function s = localGetMetaData(this,v)
s = getMetaData(this);