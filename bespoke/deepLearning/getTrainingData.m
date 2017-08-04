function [ inputData, patientOutputs, patientIds, channels, outputVars, dataOwner, patientNumber] = getTrainingData( targetEvent, outputVariableNames )
%GENERATEINPUT Summary of this function goes here
%   Detailed explanation goes here

outputFrameCount = 128;
preEvent = 1023;
postEvent = 3072;
sampleRate = 0;
channels = wahbehChannelLocs;
allEvents = [];
outputVars = outputVariableNames;

%figure out which EEGs have the event as their most common
%stricly speaking this isn't totally necessary
folder = '/home/data/EEG/processed';
load(fullfile(folder, 'eventData.mat'));
targetFileIndices = find([allEvents.commonEvent] == targetEvent);
keepIndices = find(cellfun(@length, strfind({allEvents(targetFileIndices).filename}, 'Flanker'))~=0);
targetFileIndices = targetFileIndices(keepIndices);
clear keepIndices;

inputData = [];
outputData = [];
patientNumber = [];

%get output data
if(exist('outputVariableNames'))
    [patientOutputs, patientIds, targetFileIndices, dropIndices] = getOutputData(allEvents, targetFileIndices, outputVariableNames);
else
    [patientOutputs, patientIds, targetFileIndices, dropIndices] = getOutputData(allEvents, targetFileIndices);
end

frameSkipCount = 1;

inputFolder = '/home/data/EEG/processed/wavelet2/';
allInputFilenames = dir(inputFolder);
allInputFilenames = allInputFilenames(~[allInputFilenames.isdir]);
%drop inputs that don't have corresponding outputs
filenames = allInputFilenames;
for i = length(filenames):-1:1
    filename = filenames(i).name(1:5);
    found = false;
    for j = 1:length(patientIds)
        if(strcmp(patientIds(j), filename))
            found = true;
        end
    end
    if(~found)
        filenames(i) = [];
    end
end
allInputFilenames = filenames;

%calculate total memory needed by looking at all input files
% rowTotal = 9962;
% inputWidth = 206400;
% if(~exist('rowTotal'))
rowTotal = 0;
for i = 1:length(allInputFilenames)
    filename = fullfile(inputFolder, allInputFilenames(i).name);
    S = load(filename);
    rowTotal = rowTotal + size(S.S1, 1);
    patientNumber(end+1:end+size(S.S1,1)) = i;
    inputWidth = size(S.S1,2);
end
% end
%read the input data into memory
inputData = NaN(rowTotal, inputWidth);
rowStart = 1;
for i = 1:length(allInputFilenames)
    filename = fullfile(inputFolder, allInputFilenames(i).name);
    S = load(filename);
    rowEnd = rowStart + size(S.S1, 1) - 1;
    %debug
    if(rowEnd > rowTotal)
        dummy = 1;
    end
    %end debug
    inputData(rowStart:rowEnd,:) = S.S1(:,:);
    rowStart = rowEnd + 1;
end
%%%%

getRawInput = false;
if(getRawInput)
    allInputFilenames = cell(1, length(targetFileIndices));
    index = targetFileIndices(1);
    filename = realBdfFilename(allEvents(index).filename);
    EEG = pop_readbdf(filename, {}, 43, int32(32), false);
    for i = 1:length(targetFileIndices)
        disp(sprintf('\n\n\n*****%d of %d*****\n\n\n',i,length(targetFileIndices)));
        index = targetFileIndices(i);
        filename = realBdfFilename(allEvents(index).filename);
        EEG = pop_readbdf(filename, {}, 43, int32(32), false);
        if(sampleRate == 0)
            sampleRate = EEG.srate;
            channels = {EEG.chanlocs.labels};
            frameSkipCount = (preEvent+postEvent+1)/outputFrameCount;
        end
        eventI = find([EEG.event.type] == targetEvent);
        starts = zeros(1, length(eventI));
        ends = zeros(1, length(eventI));
        for j = 1:length(eventI)
            ind2 = eventI(j);
            latency = EEG.event(ind2).latency;
            start = latency - preEvent;
            finish = latency + postEvent;
            if(start > 0 && finish <= size(EEG.data,2))
                starts(j) = latency - preEvent;
                ends(j) = latency + postEvent;
                d = EEG.data(:, starts(j):ends(j));
                dDownSampled = NaN(size(d,1), outputFrameCount);
                for k = 1:length(channels)
                    inStart = 1;
                    inEnd = frameSkipCount;
                    for l = 1:outputFrameCount
                        dDownSampled(k,l) = mean(d(k,inStart:inEnd));
                        inStart = inStart + frameSkipCount;
                        inEnd = inEnd + frameSkipCount;
                    end
                end
                df = reshape(dDownSampled, 1, size(dDownSampled,1) * size(dDownSampled,2));
                if(length(inputData) == 0)
                    inputData = df;
                    patientNumber = index;
                else
                    inputData(end+1,:) = df;
                    patientNumber(end+1) = index;
                end
            end
        end
    end
    %     save('condensed.mat');
    % end
else
    dummy = 0;
    
end

% if(exist('outputVariableNames'))
%     [patientOutputs, patientIds, targetFileIndices] = getOutputData(allEvents, targetFileIndices, outputVariableNames);
% else
%     [patientOutputs, patientIds, targetFileIndices] = getOutputData(allEvents, targetFileIndices);
% end

%handle NaN data
nanHandling = 'remove';
if(strcmp(nanHandling, 'remove'))
    removeColumn = zeros(1, size(patientOutputs,2));
    for i = 1:length(removeColumn)
        column = patientOutputs(:,i);
        if(any(isnan(column)))
            removeColumn(i)=1;
        end
    end
    patientOutputs(:,find(removeColumn)) = [];
    outputVars(find(removeColumn)) = [];
elseif(strcmp(nanHandling, 'zero'))
    %todo: implement
end

% %normalize between zero and one
% minVals = NaN(1, size(patientOutputs,2));
% maxVals = NaN(1,size(patientOutputs,2));
% for i = 1:length(minVals)
%     minVals(i) = min(patientOutputs(:,i));
%     maxVals(i) = max(patientOutputs(:,i));
%     for j = 1:size(patientOutputs,1)
%         patientOutputs(j,i) = (patientOutputs(j,i) - minVals(i)) / (maxVals(i) - minVals(i));
%     end
% end

dataOwner = patientIds;



% dataOwner = cell(1,length(patientNumber));
% for i = 1:length(dataOwner)
%     dataOwner{i} = allEvents(patientNumber(i)).filename;
% end

end

