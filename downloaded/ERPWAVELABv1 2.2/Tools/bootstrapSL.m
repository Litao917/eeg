function [QnU, QnL]=bootstrapSL(WT,measure,Bsize,SL,boottype,nrepoch,cop,sITPC)
% Calculates bootstrap signicance level
%
% Written by Morten Mørup
%
% Usage:
%       [QnU, QnL]=bootstrapSL(WT,measure,Bsize,SL,boottype,nrepoch,sITPC,NW)
%
% Input:
%   WT          4 way array of Channel x Frequency x Time x Epochs of bootstrap
%               sample region
%   measure     1x7 vector defining the specific measure to be calculated from each of the
%               measures: ITPC, ERSP, ERPCOH, avWT, INDUCED, WTav LinearCoherence
%               Thus, measure=[1 0 0 0 0 0 0]  Calculates the ITPC
%               Thus, measure=[0 1 0 0 0 0 0]  Calculates the ERSP
%               Thus, measure=[1 0 0 0 0 0 1]  Calculates the ITLC
%   Bsize       Bootstrap sample size
%   SL          Significance level
%   boottype    0: Full boostrap over all channel frequencies,
%               1: cheap bootstrap assuming same distribution deviating by
%               multiplication of constant between channel and frequencies.
%   nrepoch     Number of epochs present in data (default size(WT,4))
%   cop         vector of Cross Coherence parameters cop=[ch, fr , t, utp, ufp]
%                   ch,fr,t channel, frequency and time point coherence was
%                   originally measured from. utp, ufp use time point and
%                   frequency point respectively when calculating the cross
%                   coherence. Time point is ignored for bootstrap.
%   sITPC       1: Subtract ITPC activity from ERPCOH, 0: Don't subtract (default)
%   NW          Channel x Frequency array giving the background
%               post normalization (default: array of ones, i.e. no post
%               normalization)
%
% Output:
%   QnU         Channel x Frequency array of Upper significance limits
%   QnL         Channel x Frequency array of Lower significance limits
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

% Revision
% 31 October 2006       Bug corrected for bootstrap with post normalization
% 30 November 2006      Calculation of meausres for samples of cross
%                       coherence moved to calcmeasure.m
% 

if nargin<4
    sl=0.95;
end
if nargin<5
    boottype=0;
end
    
if nargin<6
    nrepoch=size(WT,4);
end

if nargin<8
    cop=zeros(1,5);
end

if nargin<8
    sITPC=0;
end

sWT=size(WT);

if boottype  %cheap bootstrap

    % normalize each channel - but do not amplitude correct for ITPC and ERPCOH
    if measure(1) | measure(3)
        Qn=ones(size(WT,1),size(WT,2));
    else
        Qn=mean(mean(abs(WT),3),4);
    end
    WT=WT./repmat(Qn,[1 1 sWT(3:4)]);

    sample_pop=prod(sWT);
    WT=WT(:);

    disp(['Bootstrapping, this might take a while']);
    % Create bootstrap sample
    boot_ind=ceil(sample_pop*rand(1,1,Bsize,nrepoch));
    WT1=WT(boot_ind);

    if measure(3)==1 % Measure is ERPCOH/ERLCOH
        boot_ind=ceil(sample_pop*rand(1,1,Bsize,nrepoch));
        WT1(1,2,:,:)=WT(boot_ind);
        cop=[1 2 0 0 1];
        [Y, N1, N2]=calcmeasure(WT1,measure,cop);
        Y=Y(1,1,:);
        if measure(7)==1 % ERLCOH
            N1=N1(1,1,:);
            N2=N2(1,1,:);
            Y=Y./(sqrt(N1).*sqrt(N2));
        end       
        if sITPC & ~(measure(7)==1 | measure(7)==2)
            Y=Y-abs(mean(WT1./abs(WT1),4));
            Y(Y<0)=eps;
        end
    else
        [Y, N1, N2]=calcmeasure(WT1,measure);
    end
    if measure(7)==1 & measure(1) % ITLC
        Y=Y./sqrt(nrepoch*N1);
    end
    
    if ~isreal(Y)
        sample=squeeze(abs(Y));
    else
        sample=squeeze(Y);
    end
        

    if measure(2) % ERSP
       Qn=Qn.^2;
    end

    % Two tailed analysis for all measures except ITPC and ERPCOH
    if ~measure(1) | ~measure(3)
        SL=SL+(1-SL)/2;
    end
    sample=sort(sample);

    % QnL and QnU are Ch X Frequency array of lower and upper limits
    % respectively.
    QnL=Qn*sample(ceil(length(sample)*(1-SL)));
    QnU=Qn*sample(ceil(length(sample)*SL));
else % expensive bootstrap (creates separate bootstrap for each channel and frequency
    Bs=50;
    nB=ceil(Bsize/Bs);
    sample=zeros([sWT(1:2) Bsize]);
    for k=1:nB
        if k==nB
            txt=num2str((k-1)*Bs+1);
            Bs=Bsize-(nB-1)*50;
            disp(['Operating on bootstrap sample ' txt ' - ' num2str(Bsize) ' out of ' num2str(Bsize)]);
        else
            disp(['Operating on bootstrap sample ' num2str((k-1)*Bs+1) ' - ' num2str(k*Bs) ' out of ' num2str(Bsize)]);
        end
        WT1=zeros([sWT(1:2) Bs nrepoch]);
        if measure(3)==1 % Initialize cross region
            WT2=zeros([sWT(1:2) Bs nrepoch]);
        end
        boot_ind=ceil(prod(sWT(3:4))*rand(Bs,nrepoch));
        WT1=reshape(WT(:,:,boot_ind),[sWT(1:2), Bs, nrepoch]);
        if measure(3)==1 % ERPCOH/ERLCOH generate cross coherence sample
            boot_ind=ceil(prod(sWT(3:4))*rand(Bs,nrepoch));
            WT2=reshape(WT(cop(1),:,boot_ind),[1 sWT(2), Bs, nrepoch]);
        end
        if measure(3)==1    %ERPCOH/ERLCOH analysis
            W=zeros(2,sWT(2),Bs,nrepoch);
            Y=zeros(sWT(1),sWT(2),Bs);
            if measure(7)==1
                N1=zeros(sWT(1),sWT(2),Bs);
                N2=zeros(sWT(1),sWT(2),Bs);
            end
            W=WT1;
            W(end+1,:,:,:)=WT2;
            cop2=cop;
            cop2(4)=0;
            cop2(1)=size(W,1);
            [Y,N1,N2]=calcmeasure(W,measure,cop2);
            Y=Y(1:end-1,:,:);
            if measure(7)==1 % Linear coherence
                N1=N1(1:end-1,:,:);
                N2=N2(1:end-1,:,:);
                Y=Y./(sqrt(N1).*sqrt(N2));
            end           
            if sITPC & ~(measure(7)==1 | measure(7)==2)
                Y=Y-abs(mean(WT1./abs(WT1),4));
                Y(Y<0)=eps;
            end
        else
            [Y,N1,N2]=calcmeasure(WT1,measure);
        end
        if measure(7)==1 & measure(1) % ITPC with linear coherence
            Y=Y./sqrt(nrepoch*N1);
        end
        sample(:,:,end+1:end+size(Y,3))=abs(Y);
    end
    disp(['Calculating bootstrap sample activation this might take a while']);        
    
    % Two tailed analysis for all measures except ITPC/ITLC and
    % ERPCOH/ERLCOH
    if ~measure(1) | ~measure(3)
        SL=SL+(1-SL)/2;
    end
    sample=sort(sample,3);
    % QnL and QnU are Ch X Frequency array of lower and upper limits
    % respectively.
    QnL=squeeze(sample(:,:,ceil(size(sample,3)*(1-SL))));
    QnU=squeeze(sample(:,:,ceil(size(sample,3)*SL)));   
end
