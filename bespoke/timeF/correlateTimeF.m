function [ output_args ] = correlateTimeF( input_args )
%CORRELATETIMEF Summary of this function goes here
%   Detailed explanation goes here

load('/home/data/EEG/processed/wahbehVariables.mat');
timeFFolder = '/home/data/EEG/processed/timeF/';
outputFolder = '/home/data/EEG/processed/timeFCorrelations/';
groupCutoffSize = 20;
pThreshold = 0.05;


%%load wavelet summaries into groups based on most common event
[ant1Names ant2Names tone1Names tone2Names ptsdNames] = sortFiles(timeFFolder);
allFiles = [ant1Names ant2Names tone1Names tone2Names ptsdNames];
groups = struct;
for i = 1:length(allFiles)
  file = allFiles{i};
  eventNumberStart = strfind(file, 'Event') + length('Event');
  eventNumberEnd = strfind(file, '.mat') - 1;
  event = file(eventNumberStart:eventNumberEnd);
  groupName = 'ant1e';
  fileCount = length(ant1Names);
  if(i > fileCount)
    groupName = 'ant2e';
  end
  fileCount = fileCount + length(ant2Names);
  if(i > fileCount)
    groupName = 'tone1e';
  end
  fileCount = fileCount + length(tone1Names);
  if(i > fileCount)
    groupName = 'tone2e';
  end
  fileCount = fileCount + length(tone2Names);
  if(i > fileCount)
    groupName = 'ptsde';
  end
  groupName = strcat(groupName, num2str(event));
  load(strcat(timeFFolder, file));
  if(isfield(groups, groupName))
    tempDataArray = groups.(groupName);
    tempDataArray(end+1) = data;
  else
    tempDataArray = data;
    dummy = 0;
  end
  groups.(groupName) = tempDataArray;
end

parpoolobj = gcp('nocreate');
if(length(parpoolobj) == 0)
  parpoolobj = parpool(20);
end

%%look for correlations
groupNames = fieldnames(groups);
for groupNumber = 1:length(groupNames)    %% groups
  outputs = [];
  group = groups.(groupNames{groupNumber});
  if(length(group) >= groupCutoffSize)
    varCrosswalk = zeros(1,length(group));
    remove = zeros(1, length(group));
    for i = 1:length(group)
      subjectFilename = group(i).file;
      if(strfind(groupNames{groupNumber}, 'ptsd'))
        varTable = ptsdData;
        startIndex = strfind(subjectFilename, 'PM') + 3;
        tableIds = varTable{:, 'Id'};
        subjectId = str2num(subjectFilename(startIndex:startIndex + 1));
        %debug
        disp(groupNumber);
        %end debug
        crosswalkValue = find(tableIds == subjectId);
        if(length(crosswalkValue) == 1)
          varCrosswalk(i) = crosswalkValue;
        end
      else
        varTable = vetmindData;
        startIndex = strfind(subjectFilename, 'VM');
        tableIds = varTable{:, 'ID'};
        subjectId = subjectFilename(startIndex:startIndex + 4);
        crosswalkValue = find(cellfun(@length, strfind(tableIds, subjectId)));
        if(length(crosswalkValue) == 1)
          varCrosswalk(i) = crosswalkValue;
        end
      end
    end
    group(varCrosswalk==0) = [];
    varCrosswalk(varCrosswalk==0) = [];
    
    variableNames = varTable.Properties.VariableNames;
    outputFilename = strcat(outputFolder, groupNames{groupNumber}, 'Correlations.mat');
    if(~exist(outputFilename))

    for channelNumber = 1:length(group(1).channel)       %channels
      erspSize = size(group(1).channel(channelNumber).timeF.ersp);
      tic;
        usedVariables = cell(1, length(variableNames));
        channelRs = cell(1, length(variableNames));
        channelPs = cell(1, length(variableNames));
      parfor variableNumber = 1:length(variableNames);        %variables
        variableName = variableNames{variableNumber};
        varData = varTable{:, variableNumber};
        
        if(isnumeric(varData))
          correlationR = NaN(erspSize);
          correlationP = NaN(erspSize);
          for x = 1:erspSize(1)                          %timeF matrix
            for y = 1:erspSize(2)
              corrData = NaN(length(group), 2);
              for subjectNumber = 1:length(group)        %subjects
                datum = group(subjectNumber).channel(channelNumber).timeF.ersp(x,y);
                tableIndex = varCrosswalk(subjectNumber);
                corrData(subjectNumber,1) = varData(tableIndex);
                corrData(subjectNumber,2) = datum;
              end
              [r, p] = corrcoef(corrData);
              correlationR(x,y) = r(1,2);
              correlationP(x,y) = p(1,2);
            end
          end
          
          %           output.data = group;
          %           output.correlations(channelNumber).(variableName).r = correlationR;
          %           output.correlations(channelNumber).(variableName).p = correlationP;
          %           if(length(outputs) == 0)
          %             outputs = output;
          %           else
          %             outputs(end+1) = output;
          %           end
          disp(strcat('group', num2str(groupNumber), 'var', ...
            num2str(variableNumber), 'chan', num2str(channelNumber)));
          usedVariables{variableNumber} = variableNames{variableNumber};
          channelRs{variableNumber} = correlationR;
          channelPs{variableNumber} = correlationP;
        end
      end
      toc;
      output.channel = group(1).channel(channelNumber).label;
      %output.data = group;
      for j = 1:length(usedVariables)
        piece.name = usedVariables{j};
        piece.P = channelPs{j};
        piece.R = channelRs{j};
        if(j == 1)
          output.correlations = piece;
        else
          output.correlations(end+1) = piece;
        end
      end
      [folder, pieceFilename, extension] = fileparts(outputFilename);
      pieceFilename = strcat(pieceFilename, output.channel);
      piecePath = fullfile(folder, strcat(pieceFilename, extension));
      save(piecePath, 'output');
      if(length(outputs) == 0)
        outputs = output;
      else
        outputs(end+1) = output;
      end
    end
    %save(outputFilename, 'outputs', '-v7.3');
    end
  end
end

end

