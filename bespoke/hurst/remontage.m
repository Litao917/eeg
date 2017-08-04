function [ newEeg ] = remontage( eeg )
%REMONTAGE Summary of this function goes here
%   Detailed explanation goes here

newEeg = NaN(size(eeg,1), size(eeg,2)+1);
for i = 1:size(eeg,1)
  column = eeg(i,:);
  avg = mean(column);
  newEeg(i,1:length(column)) = column - avg;
  newEeg(i,end) = -avg;
end


end

