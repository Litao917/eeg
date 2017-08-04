function generateExcelResult(FACT, chanlocs, tim, fre, filename, datasetname)
% Function generating Excel/worksheet-file summarizing the decomposition
% results
%
% Written by Morten Mørup
% 
% Usage:
%       generateExcelResult(Fact, chanlocs, tim, fre, datasetname)
%
% Input:
%       FACT         Cell array of decomposition result
%       chanlocs     The location of the channels as defined by EEGLAB
%       tim          The location of each time sample in ms. of the time dimension
%       fre          The location of each frequency sample in ms. of the
%                    frequency dimension.
%       filename     filename including path in which to save the
%                    decomposition summary
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
%
% Revision:
% 29 November 2006  Check for existence of xlswrite

if nargin==6 % Initialize summary to speed up result insertion
    summary=cell(length(datasetname)*size(FACT{2},2)+3);
end

% Generate Excel cells of FACT{1} and FACT{2}
if length(FACT)==2 & nargin==6  % 2-way Ch x Fr x Tim decomposition result
    summary{1,2}='Channel';
    summary{1,3}='Dataset/Epoch';
    summary{1,4}='Time';
    summary{1,5}='Frequency';
    summary{1,6}='TF-Value';

    H=FACT{2}';
    Q=[1 length(fre) length(tim)  size(FACT{2},1)/(length(fre)*length(tim))];
    q=0;
    for k=1:size(FACT{1},2);        
        % Generate array of dataset x frequency x time;
        Ht{k}=squeeze(unmatrizicing(H(k,:),1,Q));
        Ht{k}=permute(Ht{k},[3, 1, 2]);
        
        % Generate cells for excel sheet
        summary{q+2,1}=['Component ' num2str(k)];
        [y,i]=max(FACT{1}(:,k));
        summary{q+2,2}=chanlocs(i).labels;
        for t=1:size(Ht{k},1)
           tH=squeeze(Ht{k}(t,:,:));
           a=max(tH(:));
           a=a(1);
           [I,J]=find(tH==a);
           summary{q+t+1,3}=datasetname{t};
           summary{q+t+1,4}=tim(J(1));
           summary{q+t+1,5}=fre(I(1));
           summary{q+t+1,6}=a;
        end
        q=q+length(datasetname)+2;
    end
else     % 2-way Ch x Fr or 3-way  Ch x Fr x Tim decomposition result
    summary{1,2}='Channel';
    summary{1,3}='Time';
    summary{1,4}='Frequency';
    summary{1,5}='TF-Value';

    for k=1:size(FACT{2},2) 
        H=squeeze(unmatrizicing(FACT{2}(:,k)',1,[1 length(fre) length(tim)]));
        [I,J]=find(H==max(H(:)));
        [Y,C]=max(FACT{1}(:,k));
        summary{k+1,1}=['Component ' num2str(k)];
        summary{k+1,2}=chanlocs(C).labels;
        summary{k+1,3}=tim(J(1));
        summary{k+1,4}=fre(I(1));
        summary{k+1,5}=H(I(1),J(1));
    end
end

% Generate Excel cells of FACT{3}
if length(FACT)>2
   for k=1:size(FACT{3},1)
       summary{1,6+k}=datasetname{k};
       for j=1:size(FACT{3},2)
           summary{1+j,6+k}=FACT{3}(k,j);
       end
   end
end

% Write Excel file
if  exist('xlswrite.m','file')
    xlswrite([filename '.xls'],summary);
else % If writer doesn't exist print summary in Matlab prompt
    summary
end


