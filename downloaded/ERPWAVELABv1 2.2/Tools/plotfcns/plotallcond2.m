function plotallcond2(FACT,Core,vare,chanlocs,fre,tim,splnfile,nrdec)
% function to plot the result of a 3-way decomposition
%
% Written by Morten Mørup
%
% Usage:
%   plotallcond2(FACT,Core,vare,chanlocs,fre,tim,splnfile,nrdec)
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
%   nrdec       the number of rows used for the time-frequency montage
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
Q=[ 1 length(fre) length(tim)  size(FACT{2},1)/(length(fre)*length(tim))];
for k=1:d
    Ht{k}=squeeze(unmatrizicing(H(k,:),1,Q));
    Ht{k}=permute(Ht{k},[3, 1, 2]);
    if Core==0
        disp('');
        disp(['component ' num2str(k)]);
        [y,i]=max(W(:,k));
        disp(['max at channel ' chanlocs(i(1)).labels]);
        disp('Frequency   time     ITPC value');
        nrdec2=ceil(size(Ht{k},3)/nrdec);
        for t=1:size(Ht{k},1)
            tH=squeeze(Ht{k}(t,:,:));
            a=max(tH(:));
            a=a(1);
            [I,J]=find(tH==a);
            fr=fre(I(1));
            tm=tim(J(1));
            fprintf(' %6.4f %6.4f %6.4f \n',fr,tm,a);
            row=ceil(t/nrdec2);
            col=t-((row-1)*nrdec2);
        end
    end
end

p.nrdec=nrdec;
p.nrcol=ceil(Q(4)/nrdec);
for k=1:size(Ht{1},1)
    montagelabels(k).labels=num2str(k);
end
figure;
for k=1:d
    if length(intersect(k,[6 11 16]))>0
        figure;
    end
    
    if rem(k,5)==0
        subplot(min([d,5]),3,1+3*(5-1))   
    else
        subplot(min([d,5]),3,1+3*(rem(k,5)-1))    
    end
    T=W(:,k);
    if ~isempty(splnfile)
        headplot(T-mean(T),splnfile,'electrodes','off');  
    else
        topoplot(T,chanlocs,'maplimits',[min(min(W)) max(max(W))],'electrodes','off');
    end
    
    if rem(k,5)==0
        subplot(min([d,5]),3,[2 3]+3*(5-1))   
    else
        subplot(min([d,5]),3,[2 3]+3*(rem(k,5)-1))    
    end
    F{2}{k}=Ht{k};
    montageplot(Ht{k},montagelabels,p.nrdec,p.nrcol);    
    caxis([0 max(max(H))]);
    axis off;
    if k==1
        vexpt=num2str(vare*100);
        title(['Total var. expl.: ' vexpt(1:5) ' %']);
    end
   
end

if ~isempty(Core)
    F{1}=FACT{1};
    figure('name',['Core']);
    plotCore(Core,F,chanlocs,splnfile,1,p);
end