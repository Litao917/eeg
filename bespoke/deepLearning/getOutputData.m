function [ patientOutputs, patientIds, targetFileIndices, dropIndices ] = getOutputData( allEvents, targetFileIndices, outputVariableNames )
%GETOUTPUTDATA Summary of this function goes here
%   Detailed explanation goes here

dropIndices = [];
folder = '/home/data/EEG/processed';
load(fullfile(folder, 'wahbehVariables.mat'));
ids = vetmindData{:,1};

if(exist('outputVariableNames'))
    vetmindData = vetmindData(:,outputVariableNames);
end

include = zeros(1,size(vetmindData,2));
for i = 1:length(include)
    sample = vetmindData{1,i};
    include(i) = isnumeric(sample);
end
clear sample;
outputVars = vetmindData.Properties.VariableNames(find(include==1));

patientOutputs = NaN(length(targetFileIndices),length(outputVars));
patientIds = cell(1,length(targetFileIndices));
for i = length(targetFileIndices):-1:1
    shortId = allEvents(targetFileIndices(i)).filename;
    [foo shortId bar] = fileparts(shortId);
    shortId = shortId(1:5);
    found = false;
    for j = 1:size(vetmindData, 1)
%         shortId2 = vetmindData{j, 1};
        shortId2 = ids{j};
%         shortId2 = shortId2{1};
        shortId2 = shortId2(1:5);
        if(strcmp(shortId, shortId2))
            capsScore = vetmindData{j, outputVars};
            patientOutputs(i,:) = capsScore;
            patientIds{i} = shortId2;
            %             newVector(i) = capsScore;
            found = true;
        end
    end
    if(~found)
        dropIndices(end+1) = targetFileIndices(i);
        targetFileIndices(i) = [];
        patientOutputs(i,:) = [];
        patientIds(i) = [];
    end
end

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
%   minVals(i) = min(patientOutputs(:,i));
%   maxVals(i) = max(patientOutputs(:,i));
%   for j = 1:size(patientOutputs,1)
%     patientOutputs(j,i) = (patientOutputs(j,i) - minVals(i)) / (maxVals(i) - minVals(i));
%   end
% end

end

