function R=mat2cellstring(T)
% Function to transform a vector of numbers into a cell of strings
% representing each number.
%
% Written by Morten Mørup
% 
% Usage:
%       R=mat2cellstring(T)
%
% Input:
%       T   vector of numbers
%
% Output:
%       R   Cell of strings corresponding to each number
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

R=cell(length(T),1);
for k=1:length(T)
   R{k}=num2str(T(k));
end