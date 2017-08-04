function [ia,ib] = utIntersect(Vars1,Vars2)
% Optimized intersect for variable handles

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
nv = length(Vars1);
[c,ndx] = sort([Vars1;Vars2]);
d = find(c(1:end-1)==c(2:end));
ndx = ndx([d;d+1]);
b = ndx > nv;
ia = ndx(~b);
ib = ndx(b)-nv;
