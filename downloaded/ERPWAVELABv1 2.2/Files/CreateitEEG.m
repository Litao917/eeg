function files=CreateitEEG(savefile,wname, fb,Fa, t1,t2,dt,chantoanal,res,normmeth,lsp)
% Function call to perform time-frequency analysis
%
% Written by Morten Mørup
%
% Usage:
%   CreateitEEG(savefile,wname, fb,Fa,t1,t2,dt,chantoanal,res,normmeth,lsp)
%
% Input:
%   savefile    filename to save the ERPWAVELAB dataset to
%   wname       name of time-frequency transformation method
%   fb          Width parameter for time-frequency transformation
%   Fa          vector of 3 elements Fa(1) start frequency Fa(2) end
%               frequency Fa(3) number of frequency bins
%   t1          index of EEG.times at which to start transformation
%   t2          index of EEG.times at which to end transformation
%   dt          interval in samples between timepoints in time-frequency analysis
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
%               normmeth=1         normalize by 1/f
%               normmeth=0         no normalization
%   lsp         log frequency axis
%
%   Output:
%   files       path and name of files generated
%

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
% 6 November           Change of t1 and t2 to be in time index instead of ms.
% 19 December 2006     Output files defined.

global EEG ALLEEG CURRENTSET
if lsp
    strFa=['[logspace(' num2str(Fa(1)) ',' num2str(Fa(2)) ',' num2str(Fa(3)) ')'];
    Fa=logspace(Fa(1),Fa(2),Fa(3));
else
    strFa=['linspace(' num2str(Fa(1)) ',' num2str(Fa(2)) ',' num2str(Fa(3)) ')'];    
    Fa=linspace(Fa(1),Fa(2),Fa(3));
end
if length(chantoanal)==chantoanal(end)-chantoanal(1)+1
    strch=[num2str(chantoanal(1)) ':' num2str(chantoanal(end))];
else
    strch=num2str(chantoanal);
end
files=tfanalysis(EEG, savefile, Fa,t1,t2,dt,wname,fb,chantoanal,res,normmeth);    
EEG=eeg_hist(EEG,['tfanalysis(EEG,''' savefile ''',' strFa ',' num2str(t1) ',' num2str(t2) ',' num2str(dt) ',''' wname ''',' num2str(fb) ', [' strch '],[' num2str(res') '],[' num2str(normmeth) ']);']);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);