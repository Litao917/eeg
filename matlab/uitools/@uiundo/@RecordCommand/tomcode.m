function [str] = tomcode(hThis)

% Copyright 2002-2010 The MathWorks, Inc.

target = get(hThis,'Target');
obj = sprintf('h_%s',get(target(1),'Type'));
prop = get(hThis,'TargetProperties');
prop = prop{1};
val = '...';
comment = get(hThis,'Name');

str = sprintf('set(%s,''%s'',%s); %% %s',obj,prop,val,comment);

