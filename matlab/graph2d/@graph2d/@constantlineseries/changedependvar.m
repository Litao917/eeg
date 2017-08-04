function cline = changedependvar(cline,newvar)
% CHANGEDEPENDVAR  Change dependent variable.

%   Copyright 1984-2005 The MathWorks, Inc. 

cline.DependVar = newvar;
update(cline);