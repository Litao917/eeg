function [ output_args ] = generateNpys( outputVariableNames )
%GENERATECSVS Summary of this function goes here
%   Detailed explanation goes here

if(nargin == 0)
    outputVariableNames = {'CAPS'};
%    outputVariableNames = {'CAPS', 'BDI1'};
end

tic;
targetEvent = 209;
minValidation = 0.1;
minTest = 0.1;

disp('reading values.');
normalizedInputFilename = 'neuralNetNormalizedInput.mat';
if(exist('outputVariableNames'))
    [inputData, patientOutputs, patientIds, channels, outputVars, dataOwner, patientNumber] = getTrainingData(targetEvent, outputVariableNames);
else
    [inputData, patientOutputs, patientIds, channels, outputVars, dataOwner, patientNumber] = getTrainingData(targetEvent);
end
% if(exist(normalizedInputFilename))
%     load(normalizedInputFilename);
% else

    %compress down to half size
%     compressedInput = NaN(size(inputData,1),size(inputData,2)/2);
%     for i = 1:size(compressedInput,1)
%         for j = 1:size(compressedInput,2)
%             compressedInput(i,j) = inputData(i,j*2);
%         end
%     end
%     inputData = compressedInput;
%     clear compressedInput;

   %normalize to 1
    maxInput = max(max(inputData))
    minInput = min(min(inputData))
    coefficient = 1/(maxInput - minInput);
    disp('normalizing');
    for i = 1:size(inputData,1)
        disp(sprintf('%d of %d', i, size(inputData,1)));
        for j = 1:size(inputData,2)
            inputData(i,j) = (inputData(i,j)-minInput)*coefficient;
        end
    end
    save(normalizedInputFilename, 'inputData', 'maxInput', 'minInput', '-v7.3');
% end
toc;
%create output data by replicating the "patient data" to line up with input data
%patientCursor = 1;
%patientNumbers = [];
outputData = NaN(size(inputData,1),size(patientOutputs,2));
toc;
for i = 1:size(inputData,1)
  outputData(i,:) = patientOutputs(patientNumber(i), :);
end

%simplify filenames to be unique to each subject
for i = 1:length(dataOwner)
  [folder, filename, ext] = fileparts(dataOwner{i});
  dataOwner{i} = filename(3:5);
end
disp('assigning to groups');
longOwnerList = cell(1,length(patientNumber));
for i = 1:length(longOwnerList)
    longOwnerList{i} = patientIds{patientNumber(i)};
end
[traIn, traOut, tesIn, tesOut, valIn, valOut] = assignToGroups(inputData, outputData, longOwnerList, minTest, minValidation);
clear inputData;

varNames = {'valOut', 'tesOut', 'traOut', 'valIn', 'tesIn', 'traIn'};
csvStamp = cell(1,length(varNames)); csvStamp(1:end) = {'.csv'};
npyStamp = cell(1,length(varNames)); npyStamp(1:end) = {'.npy'};
csvNames = strcat(varNames,csvStamp);
npyNames = strcat(varNames,npyStamp);

for i = 1:length(varNames)
  csvwrite(csvNames{i}, eval(varNames{i}));
  command = '';
  command = sprintf('%secho "import numpy as np";',command);
  command = sprintf('%secho "array = np.genfromtxt(''%s'',delimiter='','')";',command, csvNames{i});
  command = sprintf('%secho "print(np.shape(array))";',command);
  command = sprintf('%secho "np.save(''%s'', arr=array)";',command, npyNames{i});
  command = sprintf('(%s) | python', command);
  unix(command);
end


if(exist('outputVariableNames'))
    outputVars = outputVariableNames;
end
toc;
notes = sprintf('summary of event %d\n   created %s\npatient ids: ', targetEvent, date);
for i = 1:length(patientIds)
  %[folder file extension] = fileparts(allEvents(targetFileIndices(i)).filename);
  notes = [notes patientIds{i} '; '];
end
notes = [notes sprintf('\noutputVariables: ')];
for i = 1:length(outputVars)
  notes = [notes outputVars{i} '; '];
end
% notes = [notes sprintf('\nvariable min Values: ')];
% for i = 1:length(minVals)
%   notes = [notes num2str(minVals(i)) '; '];
% end
% notes = [notes sprintf('\nvariable max Values: ')];
% for i = 1:length(maxVals)
%   notes = [notes num2str(maxVals(i)) '; '];
% end
notes = [notes sprintf('\nEEG channel sequence: ')];
for i = 1:length(channels)
  notes = [notes channels{i} '; '];
end
notes = [notes sprintf('\ninput data are from each channel listed above, with the first %d set of numbers corresponding to the first sample from those channels', length(channels))];
notesFilename = 'generationNotes.txt';
fileId = fopen(notesFilename, 'w');
fprintf(fileId, notes);
fclose(fileId);

%make notes:
%patient id for each row of input/output
%measure name for each column of output
%eeg info: event number
%   durations pre and post event
%   channel labels


end

