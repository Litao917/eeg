function plotNMF(FACT,Core,vare,chanlocs,fre,tim,splnfile)
% function to plot the result of a 3-way decomposition
%
% Written by Morten Mørup
%
% Usage:
%   plotNMF(FACT,Core,vare,chanlocs,fre,tim,splnfile)
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
W=FACT{1};
H=FACT{2}';
% Plot results
figure;
for k=1:d
    if length(intersect(k,[6 11 16]))>0
        figure;
    end
    
    if rem(k,5)==0
        subplot(min([d,5]),2,1+2*(5-1))   
    else
        subplot(min([d,5]),2,1+2*(rem(k,5)-1))    
    end
    if ~isempty(splnfile)
        headplot(W(:,k)-mean(W(:,k)),splnfile,'electrodes','off');  
    else
        topoplot(W(:,k),chanlocs,'maplimits',[min(W(:)) max(W(:))],'electrodes','off');
    end
    [y,i]=max(W(:,k));
     
    if rem(k,5)==0
        subplot(min([d,5]),2,2+2*(5-1))   
    else
        subplot(min([d,5]),2,2+2*(rem(k,5)-1))    
    end
     F{2}(k,:,:)=squeeze(unmatrizicing(H(k,:),1,[1 length(fre) length(tim)]));
     imagesc(tim, fre, squeeze(F{2}(k,:,:)));   
     caxis([0 max(H(:))]);
     colorbar;
     h1=xlabel('ms');
     h2=ylabel('Hz');
     set(h1,'fontweight','bold')
     set(h2,'fontweight','bold')
     
   if k==1
       vexp=num2str(vare*100);
       title(['Total var. expl. : ' vexp(1:5) ' %']);     
   end
    
end

if ~isempty(Core)
    F{1}=FACT{1};
    figure('name',['Core']);
    plotCore(Core,F,chanlocs,splnfile,1);
end