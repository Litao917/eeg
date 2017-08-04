function f = getFields(this)
%GETFIELDS  Returns list of variable and link names.

%   Copyright 1986-2004 The MathWorks, Inc.
v = [get(this.Data_,{'Variable'});get(this.Children_,{'Alias'})];
f = get(cat(1,v{:}),{'Name'});