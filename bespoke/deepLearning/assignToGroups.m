function [sets] = assignToGroups( inputData, outputData, dataOwner, minTest, minValidation)
%function [ trainingInput, trainingOutput, testInput, testOutput, validationInput, validationOutput ] = assignToGroups( inputData, outputData, dataOwner, minTest, minValidation)
%ASSIGNTOGROUPS Summary of this function goes here
%   Detailed explanation goes here

%assign data to groups
minAcceptableTestRows = length(dataOwner) * minTest;
minAcceptableValidationRows = length(dataOwner) * minValidation;
testRowCount = 0;
validationRowCount = 0;
rowIndex = 1;
testGroupFull = false;
validationGroupFull = false;
%everything starts in the training group
validationRows = zeros(1,length(dataOwner));
testRows = zeros(1, length(dataOwner));
trainingRows = ones(1, length(dataOwner));
while(rowIndex < length(dataOwner) && ~validationGroupFull)
  if(trainingRows(rowIndex)) %can be pulled into training or validation
    thisPatientId = dataOwner{rowIndex};
    %assign every data point belonging to that subject
    for i = 1:length(dataOwner)
      if(strcmp(dataOwner{i}, thisPatientId))
        if(~testGroupFull)
          testRows(i) = 1;
          testRowCount = testRowCount + 1;
          trainingRows(i) = 0;
        elseif(~validationGroupFull)
          validationRows(i) = 1;
          validationRowCount = validationRowCount + 1;
          trainingRows(i) = 0;
        end
      end
    end
    %have to change these flags after the loop so that the same subject's
    %data is all in one group
    if(~testGroupFull)
      if(testRowCount >= minAcceptableTestRows)
        testGroupFull = true;
      end
    elseif(~validationGroupFull)
      if(validationRowCount >= minAcceptableValidationRows)
        validationGroupFull = true;
      end
    end
  end
  rowIndex = rowIndex + 1;
end

sets = zeros(1, length(validationRows));
sets(find(trainingRows)) = 1;
sets(find(validationRows)) = 2;
sets(find(testRows)) = 3;

% valI = find(validationRows);
% tesI = find(testRows);
% traI = find(trainingRows);
% 
% validationInput = inputData(valI, :);
% validationOutput = outputData(valI, :);
% testInput = inputData(tesI, :);
% testOutput = outputData(tesI, :);
% trainingInput = inputData(traI, :);
% trainingOutput = outputData(traI, :);


end

