function files=tfanalysis(EEG,str,Fa,tim1,tim2,dt,wname,fb,chantoanal,res,normmeth)
% Function call to perform time-frequency analysis
%
% Written by Morten Mørup
%
% Usage:
%   [filename,pathname]=tfanalysis(EEG,str,Fa,tim1,tim2,dt,wname,fb,chantoanal,res,normmeth)
%
% Input:
%   EEG         the EEG CURRENTSET structure
%   str         pathname and filename to save the ERPWAVELAB dataset to
%   Fa          The frequencies at which transform is to be calculated
%   tim1        time index of EEG.times at which to start transformation
%   tim2        time index of EEG.times at which to end transformation
%   dt          interval between timepoints in samples for time-frequency analysis
%   wname       name of time-frequency transformation method
%   fb          Width parameter for time-frequency transformation
%   chantoanal  The indices of channels to analyze
%   res         What measures to calculate:
%                   res(i)=1 measure i is calculated, res(i)=0 measure i is
%                   not calculated.
%                   if res=[] the full time-frequency transform of all
%                   epochs is stored.
%                       res(1): ITPC
%                       res(2): ITLC
%                       res(3): ERSP
%                       res(4): avWT
%                       res(5): WTav
%                       res(6): INDUCED
%                   if res=[0 0 1 0 0 1] then both the ERSP and INDUCED is
%                   given stored in the file savefile-ERSP and
%                   sacvefile-INDUCED.
%   normmeth    if specific measures are calculated this gives how the
%               time-frequency coefficients are to be normalized prior to
%               calcuting each measure.
%               normmeth=[bt1,bt2] then data is normalized by background
%                                  activity between time sample bt1 and bt2.
%               normmeth=0         no normalization
%
%   Output:
%   files       path and name of files generated
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
% Revision:
% 6 November 2006    Change of t1 and t2 to be in time index instead of ms.
% 17 November 2006   Normalization by 1/f removed to main ERPWAVELAB program.
% 21 November 2006   Wrong output in Induced measure corrected.

Fs=EEG.srate;
X=double(EEG.data);
nrepoch=size(EEG.data,3);
chanlocs=EEG.chanlocs;
k=1;
Fc=1;
scales=Fc*Fs./Fa;
WT=[];
nepoch=size(X,3);
ITPC=0;
ITLC=0;
ITLCN=0;
ERSP=0;
avWT=0;
WTav=0;
avWTi=0;
WTavi=0;
t=0;
N=length([tim1:dt:tim2]);
if isempty(res)
    WT=zeros([length(chantoanal),length(Fa),N,size(X,3)]);
else
    WT=zeros([length(chantoanal),length(Fa),N]);
end
lc=length(chantoanal); 
if isempty(res)
    k=0;
    for j=chantoanal
        k=k+1;
        if k==1
            disp(['Operating on channel nr: ' num2str(k) '/' num2str(lc)])
        else
            disp(['Operating on channel nr: ' num2str(k) '/' num2str(lc) ' estimated time remaining ' num2str((lc-k)*(cputime-t)/60) ' minutes']);
        end
        t=cputime;
        if strcmp(wname,'Gabor (stft)')
             WT(k,:,:,:)=gabortf(squeeze(X(j,:,:)),Fa, Fs, fb,tim1:dt:tim2);
        else
             WT(k,:,:,:)=fastwavelet(squeeze(X(j,:,:)), scales, wname,fb, tim1:dt:tim2);
        end

    end
else
     lc=size(X,3); 
     for i=1:size(X,3)
        if i==1
            disp(['Operating on epoch nr: ' num2str(i) '/' num2str(lc)])
        else
            disp(['Operating on epoch nr: ' num2str(i) '/' num2str(lc) ' estimated time remaining ' num2str((lc-i)*(cputime-t)/60) ' minutes']);
        end
        t=cputime;
        if strcmp(wname,'Gabor (stft)')
             WT=gabortf(squeeze(X(chantoanal,:,i))',Fa, Fs, fb,tim1:dt:tim2);
        else
            WT=fastwavelet(squeeze(X(chantoanal,:,i))', scales, wname,fb, tim1:dt:tim2);
        end
        WT=permute(WT,[3 1 2]);
        if length(normmeth)==2
            WT=WT./repmat(mean(abs(WT(:,:,normmeth(1):normmeth(2))),3),[1 1 size(WT,3)]);
        end
        if res(1)==1
            ITPC=ITPC+WT./abs(WT);
        end
        if res(2)==1
            ITLC=ITLC+WT;
            ITLCN=ITLCN+abs(WT).^2;
        end
        if res(3)==1
            ERSP=ERSP+abs(WT).^2;
        end
        if res(4)==1
            avWT=avWT+WT;
        end
        if res(5)==1
            WTav=WTav+abs(WT);
        end
        if res(6)==1
            avWTi=avWTi+WT;
            WTavi=WTavi+abs(WT);
        end
    end
end
    
disp(['Saving file (this might take a while)']);
tim=EEG.times(tim1:dt:tim2);
wavetyp=[wname '-' num2str(fb)];
chanlocs=chanlocs(chantoanal);
files={};
if isempty(res)
    save(str, 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch');
    files{1}=str;
else
    if res(1)==1
        WT=ITPC/size(X,3);
        save([str '-ITPC'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{1}=[str '-ITPC'];
    end
    if res(2)==1
        WT=1/sqrt(size(X,3))*ITLC./sqrt(ITLCN);
        save([str '-ITLC'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{end+1}=[str '-ITLC'];
    end
    if res(3)==1
        WT=ERSP/size(X,3);
        save([str '-ERSP'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{end+1}=[str '-ERSP'];
    end
    if res(4)==1
        WT=avWT/size(X,3);
        save([str '-avWT'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{end+1}=[str '-avWT'];
    end
    if res(5)==1
        WT=WTav/size(X,3);
        save([str '-WTav'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{end+1}=[str '-WTav'];
    end
    if res(6)==1
        WT=(WTavi-abs(avWTi))/size(X,3);
        save([str '-Induced'], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        files{end+1}=[str '-Induced'];
    end
end




