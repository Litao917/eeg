function concatenateWaveletChannels( )
%GENERATEINPUT Summary of this function goes here
%   Detailed explanation goes here

%outputVars = {'CAPS', 'BDI1'};
outputFrameCount = 128;
targetEvent = 209;
preEvent = 1023;
postEvent = 3072;
sampleRate = 0;
channels = [];
allEvents = [];


% if(exist('condensed.mat', 'file'))
%   load('condensed.mat');
% else
  
  %load event file one directory up
  
  %folder = fileparts(which('generateNpys'));
  folder = '/home/data/EEG/data/wavelet';
  load('/home/data/EEG/processed/eventData.mat');
  files = dir(folder);
  for i = length(files):-1:1
    if(files(i).name(1) == '.' || ~strcmp(files(i).name(end-3:end), '.mat'))
      files(i) = [];
    end
  end
  
  load(fullfile(folder,files(1).name));
  
  searchString = 'AF3.mat';
  batchFilenameIndent = strfind({files.name}, searchString);
  batchFileNumber = find(cellfun(@length, batchFilenameIndent) > 0);
  batchFileNumber(end+1) = length(files) + 1;
  batchSpacing = diff(batchFileNumber);
  batchFileNumber(end) = [];
  channelCount = mode(batchSpacing);
  currentIndent = 0;
  outputFolder = '/home/data/EEG/processed/wavelet1/';
  if(~exist(outputFolder))
    mkdir(outputFolder);
  end

  for i = 1:length(batchFileNumber)
    if(batchSpacing(i) == channelCount) %only process complete sets      
      disp(sprintf('concatenating %d of %d', i, length(batchFileNumber)));
      index = batchFileNumber(i);      
      prefix = files(batchFileNumber(i)).name(1:batchFilenameIndent{index}-1);
      chanlocs = wahbehChannelLocs;
      for j = 1:length(chanlocs)
        source = fullfile(folder,strcat(prefix,chanlocs{j},'.mat'));
        S = load(source);
        if(j == 1)
          trialCount = length(S.fullTimeF.allErsp);
          timeFDims = size(S.fullTimeF.allErsp{1});
          channelWidth = timeFDims(1) * timeFDims(2);
          allTrials = NaN(trialCount,channelCount * channelWidth);
        end
        writeStart = (j-1) * channelWidth + 1;
        writeEnd = j * channelWidth;
        for k = 1:trialCount
          timeF = reshape(S.fullTimeF.allErsp{k}, 1, channelWidth);
          allTrials(k, writeStart:writeEnd) = timeF(:,:);
        end
      end
      destination = fullfile(outputFolder,strcat(prefix,'.mat'));
      save(destination, 'allTrials');
    end
  end
end
%   
%   filenameIndent = 0;
%   for i = 1:length(batchFilenameIndent)
%     if(length(batchFilenameIndent(i)) > 0)
%       filenameIndent = batchFilenameIndent(i);
%     end
%     
%   end
%   
%   
%   
%   targetFileIndices = find([allEvents.commonEvent] == targetEvent);
%   keepIndices = find(cellfun(@length, strfind({allEvents(targetFileIndices).filename}, 'Flanker'))~=0);
%   targetFileIndices = targetFileIndices(keepIndices);
%   clear keepIndices;
%   
%   inputData = [];
%   outputData = [];
%   patientNumber = [];
%   
%   load('/home/gmay/Documents/MATLAB/wahbehVariables.mat');
%   if(~exist('outputVars'))
%     include = zeros(1,size(vetmindData,2));
%     for i = 1:size(vetmindData, 2)
%       sample = vetmindData{1,i};
%       include(i) = isnumeric(sample);
%     end
%     clear sample;
%     outputVars = vetmindData.Properties.VariableNames(find(include==1));
%   end
%   patientOutputs = NaN(length(targetFileIndices),length(outputVars));
%   patientIds = cell(length(targetFileIndices), 1);
%   sampleRate = 0;
%   for i = length(targetFileIndices):-1:1
%     shortId = allEvents(targetFileIndices(i)).filename;
%     [foo shortId bar] = fileparts(shortId);
%     shortId = shortId(1:5);
%     found = false;
%     for j = 1:size(vetmindData, 1)
%       shortId2 = vetmindData{j, 1};
%       shortId2 = shortId2{1};
%       shortId2 = shortId2(1:5);
%       if(strcmp(shortId, shortId2))
%         capsScore = vetmindData{j, outputVars};
%         patientOutputs(i,:) = capsScore;
%         patientIds{i} = shortId2;
%         %             newVector(i) = capsScore;
%         found = true;
%       end
%     end
%     if(~found)
%       targetFileIndices(i) = [];
%       patientOutputs(i,:) = [];
%       patientIds(i) = [];
%     end
%   end
%   
%   tic;
%   frameSkipCount = 1;
%   allInputData = cell(1, length(targetFileIndices));
%   
%   index = targetFileIndices(1);
%   filename = realBdfFilename(allEvents(index).filename);
%   EEG = pop_readbdf(filename, {}, 43, int32(32), false);
%   for i = 1:length(targetFileIndices)
%     toc;
%     tic;
%     disp(sprintf('\n\n\n*****%d of %d*****\n\n\n',i,length(targetFileIndices)));
%     index = targetFileIndices(i);
%     filename = realBdfFilename(allEvents(index).filename);
%     EEG = pop_readbdf(filename, {}, 43, int32(32), false);
%         if(sampleRate == 0)
%             sampleRate = EEG.srate;
%             channels = {EEG.chanlocs.labels};
%             frameSkipCount = (preEvent+postEvent+1)/outputFrameCount;
%         end
%     eventI = find([EEG.event.type] == targetEvent);
%     starts = zeros(1, length(eventI));
%     ends = zeros(1, length(eventI));
%     for j = 1:length(eventI)
%       ind2 = eventI(j);
%       latency = EEG.event(ind2).latency;
%       start = latency - preEvent;
%       finish = latency + postEvent;
%       if(start > 0 && finish <= size(EEG.data,2))
%         starts(j) = latency - preEvent;
%         ends(j) = latency + postEvent;
%         d = EEG.data(:, starts(j):ends(j));
%         dDownSampled = NaN(size(d,1), outputFrameCount);
%         for k = 1:length(channels)
%           inStart = 1;
%           inEnd = frameSkipCount;
%           for l = 1:outputFrameCount
%             dDownSampled(k,l) = mean(d(k,inStart:inEnd));
%             inStart = inStart + frameSkipCount;
%             inEnd = inEnd + frameSkipCount;
%           end
%         end
%         df = reshape(dDownSampled, 1, size(dDownSampled,1) * size(dDownSampled,2));
%         if(length(inputData) == 0)
%           inputData = df;
%           patientNumber = index;
%         else
%           inputData(end+1,:) = df;
%           patientNumber(end+1) = index;
%         end
%       end
%     end
%   end  
% %  save('condensed.mat');  
% %end
% 
% if(exist('outputVariableNames'))
%     outputData = [];  
%   load('/home/gmay/Documents/MATLAB/wahbehVariables.mat');
%   dataTable = vetmindData{outputVars, :};
%     include = zeros(1,size(vetmindData,2));
%     for i = 1:size(vetmindData, 2)
%       sample = vetmindData{1,i};
%       include(i) = isnumeric(sample);
%     end
%     clear sample;
%     outputVars = vetmindData.Properties.VariableNames(find(include==1));
% 
%   patientOutputs = NaN(length(targetFileIndices),length(outputVars));
%   patientIds = cell(length(targetFileIndices), 1);
%   sampleRate = 0;
%   for i = length(targetFileIndices):-1:1
%     shortId = allEvents(targetFileIndices(i)).filename;
%     [foo shortId bar] = fileparts(shortId);
%     shortId = shortId(1:5);
%     found = false;
%     for j = 1:size(vetmindData, 1)
%       shortId2 = vetmindData{j, 1};
%       shortId2 = shortId2{1};
%       shortId2 = shortId2(1:5);
%       if(strcmp(shortId, shortId2))
%         capsScore = vetmindData{j, outputVars};
%         patientOutputs(i,:) = capsScore;
%         patientIds{i} = shortId2;
%         %             newVector(i) = capsScore;
%         found = true;
%       end
%     end
%     if(~found)
%       targetFileIndices(i) = [];
%       patientOutputs(i,:) = [];
%       patientIds(i) = [];
%     end
%   end
% end
% 
% %handle NaN data
% nanHandling = 'remove';
% if(strcmp(nanHandling, 'remove'))
% removeColumn = zeros(1, size(patientOutputs,2));
% for i = 1:length(removeColumn)
%   column = patientOutputs(:,i);
%   if(any(isnan(column)))
%     removeColumn(i)=1;
%   end
% end
% patientOutputs(:,find(removeColumn)) = [];
% outputVars(find(removeColumn)) = [];
% elseif(strcmp(nanHandling, 'zero'))
%   %todo: implement
% end
% 
% %normalize between zero and one
% minVals = NaN(1, size(patientOutputs,2));
% maxVals = NaN(1,size(patientOutputs,2));
% for i = 1:length(minVals)
%   minVals(i) = min(patientOutputs(:,i));
%   maxVals(i) = max(patientOutputs(:,i));
%   for j = 1:size(patientOutputs,1)
%     patientOutputs(j,i) = (patientOutputs(j,i) - minVals(i)) / (maxVals(i) - minVals(i));
%   end
% end
% 
% dataOwner = cell(1,length(patientNumber));
% for i = 1:length(dataOwner)
%   dataOwner{i} = allEvents(patientNumber(i)).filename;
% end
% 
% end

