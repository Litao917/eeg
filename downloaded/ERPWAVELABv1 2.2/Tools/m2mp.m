function tp=m2mp(tim, t)
% Finds the index in tim the closest to t
%
% Written by Morten Mørup
%
% Usage:
%       tp=m2mp(tim, t)
%
% Input:
%       tim vector of samplelocations
%       t   location of interest
%
% Output:
%       tp  index of sample closest to t
%
% Copyright (C) Morten Mørup and Technical University of Denmark, 
% September 2006
%                                          
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

[m,tp]=min((t-tim).^2);
tp=tp(1);
