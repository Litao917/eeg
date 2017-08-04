function [ eegdb ] = getData( outputVariableNames )
%GETDATA Summary of this function goes here
%   Detailed explanation goes here
  if(~exist('outputVariableNames'))
    outputVariableNames = {'Education'};
  end
  targetEvent = 209;
  [inputData, patientOutputs, patientIds, channels, outputVars, dataOwner, patientNumber] = getTrainingData(targetEvent, outputVariableNames);
  outputData = NaN(size(inputData,1),size(patientOutputs,2));
  for i = 1:size(inputData,1)
    outputData(i,:) = patientOutputs(patientNumber(i), :);
  end
%   downsampleRate = 10;
%   x = NaN(size(inputData,1), size(inputData,2)/downsampleRate);
%   for i = 1:size(x,2)
%     inStart = (i-1)*downsampleRate + 1;
%     inEnd = inStart + downsampleRate - 1;
%     column = inputData(:, inStart:inEnd);
%     x(:, i) = mean(column, 2);
%   end
%   clear inputData;
  inputData = log(inputData);
  inputData(isinf(inputData)) = -(max(max(inputData)));
  
  if(size(inputData,2) ~= size(outputData,2))
    if(size(inputData,1) == size(outputData,1))
      outputData = outputData';
      inputData = inputData';
    end
  end
  
  
maxVal = max(inputData);
bottom = min(maxVal);
keep = find(maxVal > bottom);
inputData = inputData(:, keep);
outputData = outputData(:,keep);

nchan = 43;
nfreq = 24;
width = size(inputData,1) / nchan / nfreq;
duration = size(inputData,2);
%a = reshape(inputData, nfreq, width, nchan, duration);
b = NaN(nfreq * nchan, width, duration);

tic;
for i4 = 1:duration
  counter = 1;
  for i3 = 1:nchan
    for i2 = 1:width
      for i1 = 1:nfreq
        writeRow = nfreq * (i3-1) + i1;
        b(writeRow, i2, i4) = inputData(counter,i4);
        counter = counter + 1;
      end
    end
  end
end
longOwnerList = cell(1,length(patientNumber));
for i = 1:length(longOwnerList)
    longOwnerList{i} = patientIds{patientNumber(i)};
end 
longOwnerList = longOwnerList(keep);
eegdb.images.data = reshape(b, size(b,1),size(b,2),1,size(b,3));
eegdb.images.data_mean = mean(b,3);
eegdb.images.labels = outputData;
eegdb.images.set = assignToGroups(inputData,outputData,longOwnerList,0.1,0.1);
eegdb.meta.sets = {'train'  'val'  'test'};
eegdb.meta.classes = strread(num2str(unique(outputData)),'%s')';
save('/home/data/EEG/processed/matCnnInput.mat', 'eegdb');

end

