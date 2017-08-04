function setContents(this,s,Vars)
%SETCONTENTS  Sets values of all variable and link.

%   Copyright 1986-2004 The MathWorks, Inc.
if nargin==2
   Vars = [getvars(this); getlinks(this)];
end
for ct=1:length(Vars)
   vn = Vars(ct).Name;
   this.(vn) = s.(vn);
end