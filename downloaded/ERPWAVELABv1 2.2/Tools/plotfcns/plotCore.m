function plotCore(Core,F,chanlocs,splnfile,kp,p);

% Function to plot one slice of the Core obtained from a TUCKER analysis
%
% Written by Morten Mørup
%
% Usage:
%   plotCore(Core,F,chanlocs,splnfile,kp,p);
%
% Input:
%   Core        The core array
%   F           Cell array of factors, i.e. F{1} pertains to first modality
%   chanlocs    The channel locations
%   splnfile    The location of the splinefile if available, else set
%               splnfile=[]
%   kp          the current Core part to plot, corresponding to F{3}(:,kp)
%   p           p.nrdec,p.nrcol  creates a montageplot of F{2} with p.nrdec
%               rows and p.nrcol number of columns. (optional)
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

h = gcf;
clf;
set(h, 'Color', [1 1 1]);
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperType', '<custom>');
set(h, 'PaperPosition', [0 0 12 12]);

d=size(F{1},2);
air=0.1; % percent air between plots;
s=(d+1)+(d+2)*air;

s_d=1/s;
s_air=air/s;

h = axes('position', [0 0 1 1]);
set(h, 'Visible', 'off');
if length(F)==3
    h = axes('position', [s_air,d*s_air+d*s_d, s_d, s_d]);
    bar(F{3}(:,kp))
end
axis off;
for k=1:d
    h = axes('position', [s_air, k*s_air+(k-1)*s_d, s_d, s_d]);
    if isempty(splnfile)
        topoplot(F{1}(:,end-k+1),chanlocs,'maplimits',[min(F{1}(:)) max(F{1}(:))],'electrodes','off');
    else
        headplot(F{1}(:,end-k+1)-mean(F{1}(:,end-k+1)),splnfile,'electrodes','off');  
    end
end

for k=1:d
    h = axes('position', [k*s_d+(k+1)*s_air, d*s_air+d*s_d, s_d, s_d]);
    if nargin<6
        imagesc(squeeze(F{2}(k,:,:)));
    else
        montageplot(F{2}{k},chanlocs,p.nrdec,p.nrcol);
    end
    axis off;
end
h = axes('position', [ 2*s_air+s_d,s_air,(d-2)*s_air+d*s_d, (d-2)*s_air+d*s_d]);
hinton(Core(:,:,kp),[],[],max(Core(:)));

pause(0.000001) % insure processing time for plot