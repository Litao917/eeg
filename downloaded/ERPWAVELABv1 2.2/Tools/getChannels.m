function act_chan_ind=getChannels(chantoanal, chans)
% Function to find the indices in use, i.e. what channels are not removed.
% In epoch mode channels corresponds to epochs.
%
% Written by Morten Mørup
%
% Usage:
%   act_chan_ind=getChannels(chantoanal, chans)
%
% Input:
%   chantoanal      The channel number corresponding to each indices in the
%                   time-frequency transformed array
%   chans           the channels to disregard
%
% Output:
%   act_chan_ind    the channel indices to use
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

act_chan_ind=setdiff(chantoanal,chans);