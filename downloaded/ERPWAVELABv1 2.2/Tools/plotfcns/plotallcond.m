function plotallcond(FACT,Core,vare,chanlocs,fre,tim,splnfile)
% function to plot the result of a 3-way decomposition
%
% Written by Morten Mørup
%
% Usage:
%   plotallcond(FACT,Core,vare,chanlocs,fre,tim,splnfile)
%
% Input:
%   FACT        Cell array of the factors found from the decomposition
%   Core        The core found, if the PARAFAC model was used Core=[]
%   vare        The explained variance
%   chanlocs    The location of the channels corresponding to the rows of FACT{1}
%   fre         The frequencies corresponding to the rows of FACT{2}
%   tim         The timepoints correspondingto the rows of FACT{3}
%   splnfile    The name and path to the splinefile for 3-D scalp plot, if
%               [] no 3-D plot is generated
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

d=size(FACT{1},2);
figure;
for k=1:d
    if length(intersect(k,[6 11 16]))>0
        figure;
    end
    
    T=FACT{1}(:,k);
    if rem(k,5)==0
        subplot(min([d,5]),3,1+3*(5-1))   
    else
        subplot(min([d,5]),3,1+3*(rem(k,5)-1))    
    end
    if ~isempty(splnfile)
        headplot(T-mean(T),splnfile,'electrodes','off');  
    else
        topoplot(T,chanlocs,'maplimits',[min(min(FACT{1})) max(max(FACT{1}))],'electrodes','off');
    end
    [y,i]=max(T);  
    if rem(k,5)==0
        subplot(min([d,5]),3,2+3*(5-1))   
    else
        subplot(min([d,5]),3,2+3*(rem(k,5)-1))    
    end
    F{2}(k,:,:)=squeeze(unmatrizicing(FACT{2}(:,k),1,[1 length(fre), length(tim)]));
    imagesc(tim, fre,squeeze(F{2}(k,:,:)) );
    caxis([0 max(max(FACT{2}))]);
    h1=xlabel('ms');
    h2=ylabel('Hz');
    set(h1,'fontweight','bold')
    set(h2,'fontweight','bold')
%     colorbar;
    if k==1
        vexpt=num2str(vare*100);
        title(['Total var. expl.: ' vexpt(1:5) ' %']);
    end
    if rem(k,5)==0
        subplot(min([d,5]),3,3+3*(5-1))   
    else
        subplot(min([d,5]),3,3+3*(rem(k,5)-1))    
    end
     bar(FACT{3}(:,k));
     axis([0.5 size(FACT{3},1)+0.5 0 max(FACT{3}(:))]);
end
if ~isempty(Core)
    F{1}=FACT{1};
    F{3}=FACT{3};
    for k=1:d
        figure('name',['Core-' num2str(k)]);
        plotCore(Core,F,chanlocs,splnfile,k);
    end
end