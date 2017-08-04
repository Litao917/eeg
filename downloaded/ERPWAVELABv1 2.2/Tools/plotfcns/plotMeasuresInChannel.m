function plotMeasuresInChannel(WT,ch,name,bt,tim,fre,tp,fp)

% Generates two figures:
% Figure 1: Plot the ITPC, ITLC, ERSP, WTav, avWT and INDUCED of a given channel.
% Figure 2: A surface plot of WTav and avWT
%
% Written by Morten Mørup
%
% Usage:
%
% plotMeasuresInChannel(WT,ch,name,bt,tim,fre)
%
% Input:  
%   WT          4-way array of Channel x Frequency X Time X Epoch of time-frequency
%               transformed EEG data.
%   ch          The given channel
%   name        The name of the channel
%   bt          Indices of time region to post normalize. If empty no
%               postnormalization. Whereas data of first figure can be
%               postnormalized, figure 2 containing a surface plot of WTav
%               and avWT is not postnormalized.
%   tim         Time axis (length(tim)=size(WT,3))
%   fre         Frequency axis (length(fre)=size(WT,2))
%   tp          tp(1) start time index of WT, tp(2) end time index of WT,
%               default: tp(1)=1, tp(2)=size(WT,3)
%   fp          fp(1) start frequency index of WT, fp(2) end frequency index of WT,
%               default: fp(1)=1, fp(2)=size(WT,2)
%
% Copyright (C) Morten Mørup and Technical University of Denmark, 
% November 2006
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

if nargin<8 | isempty(fp)
    fp(1)=1;
    fp(2)=size(WT,2);
end

if nargin<7 | isempty(tp)
    tp(1)=1;
    tp(2)=size(WT,3);
end

measure{1}=[1 0 0 0 0 0 0];
measure{2}=[1 0 0 0 0 0 1];
measure{3}=[0 1 0 0 0 0 0];
measure{4}=[0 0 0 0 0 0 0];
measure{5}=[0 0 0 1 0 0 0];
measure{6}=[0 0 0 0 1 0 0];
meastype{1}='ITPC';
meastype{2}='ITLC';
meastype{3}='ERSP';
meastype{4}='WTav';
meastype{5}='avWT';
meastype{6}='Induced';

h1=figure('Name',name);
h2=figure('Name',[name 'WTav and avWT']);
for k=1:6
    [Y, N1, N2]=calcmeasure(WT(ch,:,:,:),measure{k},[]);
    if k==2 % ITLC
        Y=Y./sqrt(size(WT,4)*N1);
    end

    if k==4 | k==5 % Create surface plot of WTav and avWT and Induced
        figure(h2)
        subplot(1,2,1)
        hold on;
        surf(tim,fre,abs(squeeze(Y(1,fp(1):fp(2),tp(1):tp(2)))),'EdgeAlpha',0);
        axis tight;
        Title('WTav and avWT');
        view(-30,45);
    elseif k==6
        figure(h2)        
        subplot(1,2,2)
        hold on;
        surf(tim,fre,abs(squeeze(Y(1,fp(1):fp(2),tp(1):tp(2)))),'EdgeAlpha',0);
        axis tight;
        Title('Induced');
        view(-30,45);
        
    end

    figure(h1)
    subplot(2,3,k);
    if ~isempty(bt)
        Y=Y./repmat(mean(abs(Y(:,:,bt)),3),[1,1,size(Y,3)]);
    end
    Y=abs(squeeze(Y(1,fp(1):fp(2),tp(1):tp(2))));
    imagesc(tim,fre,Y);
    title(meastype{k});
    if k==4
        ax=[0 max(Y(:))];
    end
    if k>=4 & isempty(bt)
        caxis(ax);
    end
    colorbar;
end
