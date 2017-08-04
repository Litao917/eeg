function plotcoh(chanlocs,rect)

% Plots recorded cross coherences in a topographical display with arrows
% indicating strenght and direction of coherence
%
% Written by Morten Mørup
%
% Usage:
%   plotcoh(chanlocs,rect)
%
% Input:
%   chanlocs    structure containing the locations of each channel
%   rect        cell array of recorded cross coherences
%               rect{i}=[ch fr tm val ch2 fr2 tm2 sl p]
%               where ch,fr,tm and ch2,fr2,tm2 are the channel-frequency-time points in
%               which the cross coherence was measured and calculated from
%               respectively. val is the value of the coherence and sl the
%               significance level of the strenght of the activity p the von-mises statistics of the phase (optional).
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

% Revision:
% 15 September 2006     correction of arrows and creation of lines for same
%                       time instances.
% 23 Oktober 2006       correction of channel text 
%
% 15 November 2006      Possibility of include phase statistics (p) in plot
%
% 1 December 2006       Update to plot coherence when using only same time
%                       or frequency instanec


nrec=length(rect);
figure;
radius=[chanlocs(:).radius];
r=max(radius);
if r>0.5
    radius=radius/r*0.5;
end
 for k=1:length(chanlocs)
     chanlocs(k).radius=radius(k);
 end
c1=[rect{:}];
c1=c1(4:8:end);
c1=max(c1);
for k=1:nrec   
    rec=rect{k};
    if rem(k,4)==0
        p=4;
    else
        p=rem(k,4);
    end
	subplot(2,2,p)
    topoplot([],chanlocs, 'style', 'blank','electrodes','labelpoint');
    hold on;
    chloc1=chanlocs(rec(1));
	chloc2=chanlocs(rec(5));
    label1=chanlocs(rec(1)).labels;
    label2=chanlocs(rec(5)).labels;
    
    X=[chloc1.radius*sin(chloc1.theta/180*pi); chloc2.radius*sin(chloc2.theta/180*pi)];
	Y=[chloc1.radius*cos(chloc1.theta/180*pi); chloc2.radius*cos(chloc2.theta/180*pi)];
    hold on;
    c=1-rec(4)/c1;
    if  rec(7)==rec(3)   % Same time instance 
        line([X(1) X(2)],[Y(1) Y(2)],'linewidth',2,'color',[c c c]);
    else    % Different time instance - create arrow
        arrow([X(2) Y(2)],[X(1) Y(1)],'length',5,'width',2,'BaseAngle', 90,'TipAngle',50,'color',[c c c]);
    end
    t{1}=['Channel ' label2 '\rightarrow' label1 '   time: ' num2str(rec(7)) '\rightarrow' num2str(rec(3)) ];
    t{2}=[' freq: ' num2str(rec(6)) '\rightarrow' num2str(rec(2)) '   value: ' num2str(rec(4)) ' \alpha=' num2str(rec(8))];
    if length(rec)==9
         t{2}=[t{2} ' \beta=' num2str(rec(9))];
    end
    
    title(t);
	hold off;
    if rem(k,4)==0 & k~=nrec
        figure;
    end
end

figure;
topoplot([],chanlocs, 'style', 'blank', 'electrodes', 'labelpoint');
hold on;
for k=1:nrec   
    rec=rect{k};
    chloc1=chanlocs(rec(1));
	chloc2=chanlocs(rec(5));
    X=[chloc1.radius*sin(chloc1.theta/180*pi); chloc2.radius*sin(chloc2.theta/180*pi)];
	Y=[chloc1.radius*cos(chloc1.theta/180*pi); chloc2.radius*cos(chloc2.theta/180*pi)];
    c=1-rec(4)/c1;
    if rec(3)==rec(7)   % Same time instance 
        line([X(1) X(2)],[Y(1) Y(2)],'linewidth',2,'color',[c c c]);
    else    % Different time instances, thus create arrow
        arrow([X(2) Y(2)],[X(1) Y(1)],'length',3,'width',2,'BaseAngle', 90,'TipAngle',50,'color',[c c c]);
    end
    
end
title(['All recorded interactions']);
hold off;
