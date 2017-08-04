function analyzeallcond2(X,d,chanlocs,tim,fre, nrdec, meth, splnfile, datasetname)
% Function for 3-way decomposition of channel x time-frequency x dataset
%
% Written by Morten Mørup
% 
% Usage:
%       analyzeallcond2(X,d,chanlocs,tim,fre, nrdec, meth, splnfile)
%
% Input:
%       X            the 3-way array of channel x time-frequency-dataset
%       d            number of components
%       chanlocs     The location of the channels as defined by EEGLAB
%       tim          The location of each time sample in ms. of the time dimension
%       fre          The location of each frequency sample in ms. of the
%                    frequency dimension.
%       nrdec        Number of rows used in the resulting montage plot of
%                    time-frequency activities over each dataset
%       meth         structure specifying algortihm parameters, same as
%                    structure used in HONTF and NMWF but includes the
%                    following field:
%                    .type   'HONTF' or 'NMWF' specifying what algorithm to
%                    use.
%       splnfile     The name and path to the splinefile for 3-D scalp plot, if
%                    [] no 3-D plot is generated
%       datasetname  Cell array containing the name of each dataset
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

% Edit History
% 9 October 2006:    Generate Excel file summarizing decomposition results 
                  

P=size(X);
if length(P)==2
    SS(4)=1;
else
    SS(4)=P(3);
end
    
X=matrizicing(X,1);
lambda=zeros(1,ndims(X));

if strcmp(meth.type,'HONMF')
    [Core, FACT,vare]=honmf(X,repmat(d,[1,ndims(X)]),meth);
    p=max(FACT{1})+eps;
    s=max(FACT{2})+eps;
    FACT{1}=FACT{1}*diag(1./p);
    FACT{2}=FACT{2}*diag(1./s);
    Core=tmult(tmult(Core,diag(p),1),diag(s),2);
else
    meth.lambda=meth.lambda(2:3);
    [FACT,vare]=nmwf(X,d,meth);
    Core=[];
    p=max(FACT{1})+eps;
    FACT{1}=FACT{1}*diag(1./p);
    FACT{2}=FACT{2}*diag(p);
end
[filename, pathname] = uiputfile('decompositionresult.mat', 'Save decomposition result as');
if filename(1)~=0 & pathname(1)~=0
    save([pathname filename],'FACT','Core','vare','chanlocs','fre','tim','splnfile','SS','nrdec');
    generateExcelResult(FACT, chanlocs, tim, fre, [pathname filename],datasetname);
end
plotallcond2(FACT,Core,vare,chanlocs,fre,tim,splnfile,nrdec)
