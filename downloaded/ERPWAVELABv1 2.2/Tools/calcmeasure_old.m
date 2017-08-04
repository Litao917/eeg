function [Y, N1, N2]=calcmeasure(WT,measure,cop)

% Calculates the specified measure
%
% Written by Morten Mørup
%
% Usage:
%
%   [Y, N1, N2]=calcmeasure(WT,ss,cop)
%
% Input:  
%   WT          4-way array of Channel x Frequency X Time X Epoch of time-frequency
%               transformed EEG data.
%   measure     1x7 vector defining the specific measure to be calculated from each of the
%               measures: ITPC, ERSP, ERPCOH, avWT, induced, WTav LinearCoherence
%               Thus, measure=[1 0 0 0 0 0 0]  Calculates the ITPC
%               Thus, measure=[0 1 0 0 0 0 0]  Calculates the ERSP
%               Thus, measure=[1 0 0 0 0 0 1]  Calculates the ITLC
%   cop         used for the ERPCOH to specify chxfrxtim point as well as wether
%               ITPC is to be subtracted the ERPCOH, thus
%               cop(1) coherence channel index
%               cop(2) coherence frequency index
%               cop(3) coherence time index
%               cop(4) 1: ITPC is subtracted 0: ITPC is not subtracted.
%               default: cop=[0 0 0 0]
%
% Output:
%   Y           The calculated measure
%   N1          Used to specify normalization of ITLC, i.e.
%               ITLC=Y./sqrt(size(WT,4)*N1)
%   N2          used to specify normalization of ERLCOH, i.e 
%               ERLCOH=Y./sqrt(N1.*N2)
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

if nargin<3
    cop=zeros(1,4);
end

N1=[];
N2=[];

% Check if all epochs are present
if size(WT,4)>1
    
    % Calculate ITPC or ITLC
    if measure(1)==1
        if measure(7) %ITLC
             Y=sum(WT,4);    
             N1=sum(abs(WT).^2,4);
        else    %ITPC
            Y=mean(WT./abs(WT),4);    
        end
    % Calculate ERSP    
    elseif measure(2)==1
        Y=mean(abs(WT).^2,4);
        
    % Calculate ERPCOH/ERLCOH    
    elseif measure(3)==1    
        ch=cop(1);            
        f=cop(2);   
        t=cop(3);
        Y=0;
        sWT=size(WT);
        if cop(4)  %Substract ITPC
                if measure(7) % ERLCOH
                    Y=sum(repmat(conj(WT(ch,f,t,:)),[sWT(1:3) 1]).*WT,4);
                    N1=repmat(sum(abs(WT(ch,f,t,:)).^2,4),[sWT(1:3)]);
                    N2=sum(abs(WT).^2,4);
                else    % ERPCOH
                    Y=mean(repmat(conj(WT(ch,f,t,:))./abs(WT(ch,f,t,:)),[sWT(1:3) 1]).*(WT./abs(WT)),4);
                end
        else    % Do not substact ITPC
                if measure(7) %ERLCOH
                    Y=sum(repmat(conj(WT(ch,:,:,:)),[size(WT,1),1,1,1]).*WT,4);                    
                    N1=repmat(sum(abs(WT(ch,:,:,:)).^2,4),[sWT(1),1,1]);
                    N2=sum(abs(WT).^2,4);
                else    %ERPCOH
                    Y=mean(repmat(conj(WT(ch,:,:,:))./abs(WT(ch,:,:,:)),[size(WT,1),1,1,1]).*(WT./abs(WT)),4);
                end
        end
        if cop(4)
            WT=abs(WT);
            WT=WT-repmat(mean(WT,4),[1 1 1 size(WT,4)]);
            WT=WT./repmat(mean(WT.^2,4),[1 1 1 sWT(4)])
            Y=mean(repmat(WT(ch,f,t,:),[sWT(1:3) 1]).*WT,4);
        else
            WT=abs(WT);
            WT=WT-repmat(mean(WT,4),[1 1 1 size(WT,4)]);
            WT=WT./repmat(mean(WT.^2,4),[1 1 1 sWT(4)])
            Y=mean(repmat(WT(ch,:,:,:),[sWT(1),1,1,1]).*WT,4);
        end

        
    % avWT   
    elseif measure(4)==1
        Y=mean(WT,4); 
    
    %Induced    
    elseif measure(5)==1
        Y=mean(abs(WT),4)-abs(mean(WT,4));   
    
    % WTav
    else
        Y=mean(abs(WT),4);
    end
else    % No epochs are present so the specific measure is returned
    Y=WT;
    if measure(7) % Set N1 to default such that measure is unaltered during further processing by other potential functions
        N1=ones(size(Y));
    end
end