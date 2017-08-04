function bootstrapjknife(Y,measure,boots,Yf)
% bootstrap and jack knifing to establish the distribution and stability of
% the currently calculated measure at the currently inspected
% channel-time-frequency point. Results are displayed in a generated plot.
%
% Written by Morten Mørup
% 
% Usage: 
%       bootstrapjknife(Y,measure,boots,Yf)
%
% Input:
%       Y           the values of WT at the current point
%       measure     1x7 vector defining the specific measure to be calculated from each of the
%                   measures: ITPC, ERSP, ERPCOH, avWT, induced, WTav LinearCoherence
%                   Thus, measure=[1 0 0 0 0 0 0]  Calculates the ITPC
%                   Thus, measure=[0 1 0 0 0 0 0]  Calculates the ERSP
%                   Thus, measure=[1 0 0 0 0 0 1]  Calculates the ITLC
%       boots       the boostrap sample size
%       Yf          the values of WT at cross coherence point (optional)
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
%
% Revision
% 30 November 2006      Cross coherence calculation moved to the calcmeasure function

if nargin<4
    Yf=Y;
end
if nargin<3
    boots=1000;
end

disp('Calculating bootstrap')
% Generate bootstrap sample
X=ceil(length(Y)*rand(boots,length(Y)));
sample(1,1,:,:)=Y(X);
% Set dimensions of Y such that calcmeasure can be used
sY(1,1,1,:)=Y;

if measure(3)==0 % Make sure current measure isn't ERPCOH/ERLCOH
    [Ys, N1, N2]=calcmeasure(sample,measure);
    [Yr, N1r, N2r]=calcmeasure(sY,measure);
    Ys=abs(squeeze(Ys));
    Yr=abs(squeeze(Yr));
    if measure(1) & measure(7)  % Correct if necessary for linear coherence
        Ys=Ys./sqrt(size(sample,4)*squeeze(N1));
        Yr=Yr./sqrt(size(sY,4)*squeeze(N1r));
    end
elseif measure(3)>=1 % ERPCOH/ERLCOH
    sample(1,2,:,:)=Yf(X);
    sY(1,1,2,:)=Yf;
    cop1=[1 2 0 0 1];    
    cop2=[1 1 size(sY,3) 1 1];
    [Ys, N1, N2]=calcmeasure(sample,measure,cop1);
    if measure(7)==1 % Correct for linear coherence
        Ys=Ys./(sqrt(N1).*sqrt(N2));       
    end
    if ~isreal(Ys) % If measure is complex take absolute value
        Ys=squeeze(abs(Ys(1,1,:)));
    else
        Ys=squeeze(Ys(1,1,:));
    end
    [Yr, N1r, N2r]=calcmeasure(sY,measure,cop2);
    if measure(7)==1 % Correct for linear coherence
        Yr=Yr./(sqrt(N1r).*sqrt(N2r));       
    end
    if ~isreal(Yr) % If measure is complex take absolute value
        Yr=abs(Yr(1));
    else
        Yr=Yr(1);
    end
end
if measure(3)==2    % Subtract ITPC
    Ys=Ys-squeeze(abs(mean(sample./abs(sample(:,1)),2)));
    Yr=Yr-abs(mean(Y./abs(Y)));
end

% Plot bootstrap results
figure;
subplot(1,2,1);
hist(Ys);
sigma=std(Ys);
hold on;
plot([Yr; Yr],get(gca,'YLim'),'r-','linewidth',2);
plot([Yr-2*sigma; Yr-2*sigma],get(gca,'YLim'),'r:','linewidth',2);
plot([Yr+2*sigma; Yr+2*sigma],get(gca,'YLim'),'r:','linewidth',2);
hold off;
title('Bootstrap result')
xlabel('Results given without post normalization')
clear sample;


disp('Calculating leave one out')
% Generate leave one out samples
for k=1:length(Y)
   sample(1,1,k,:)=Y([1:k-1 k+1:end]);
   sample2(1,1,k,:)=Yf([1:k-1 k+1:end]);
end

if measure(3)==0 % Make sure current measure isn't ERPCOH/ERLCOH
    [Ys,N1,N2]=calcmeasure(sample,measure);
    Ys=abs(squeeze(Ys));
    if measure(1) & measure(7)==1 % Correct if necessary for linear coherence
        Ys=Ys./sqrt(size(sample,4)*squeeze(N1));
    end
elseif measure(3)>=1 % ERPCOH/ERLCOH/AmpCorr
    samplefull(1,1,:,:)=sample;
    samplefull(1,2,:,:)=sample2;
    cop=[1 2 0 0 1];    
     [Ys, N1, N2]=calcmeasure(samplefull,measure,cop);
    if measure(7)==1 % Correct for linear coherence
        Ys=Ys./(sqrt(N1).*sqrt(N2));       
    end
    if  ~isreal(Ys) % If measure is complex take absolute value
        Ys=squeeze(abs(Ys(1,1,:)));
    else
        Ys=squeeze(Ys(1,1,:));
    end
end
if measure(3)==2 % Subtract ITPC activity
    Ys=Ys-squeeze(abs(mean(sample./abs(sample(:,1)),2)));
    Yr=Yr-squeeze(abs(mean(sample2./abs(sample2))));
end

% Plot results obtained by leave one out
subplot(1,2,2);
hist(Ys);
sigma=std(Ys);
hold on;
plot([Yr Yr],get(gca,'YLim'),'r-','linewidth',2);
plot([Yr-2*sigma; Yr-2*sigma],get(gca,'YLim'),'r:','linewidth',2);
plot([Yr+2*sigma; Yr+2*sigma],get(gca,'YLim'),'r:','linewidth',2);
hold off;
title('Leave one out result')
[y,k1]=min(Ys);
[y,k2]=max(Ys);
a{1}=['Epoch left out causing smallest value ' num2str(k1)];
a{2}=['Epoch left out causing largest value ' num2str(k2)];
xlabel(a);