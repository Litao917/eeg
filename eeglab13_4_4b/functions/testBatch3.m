

function [  ] = testBatch3(  )
%TESTBATCH3 Summary of this function goes here
%   Detailed explanation goes here

inputFolder = '/Users/Geoff/Box Sync/For Geoff Mays/VET MIND EEG files/';
%inputFolder = '/Users/Geoff/Box Sync/For Geoff Mays/PTSD MIND EEG Files';
outputFolder = '/Users/Geoff/Box Sync/For Geoff Mays/Topography/';

[tones, ant, other] = getBdfFiles();
% allFiles = [ant];
allFiles = cell(0);
files = dir(inputFolder);
for i = 1:length(files)
    file = files(i).name;
    if(strfind(file, '.bdf'))
        allFiles{length(allFiles)+1} = file;
    end
end

for i = 30:length(allFiles)
    saveResults = strcat(outputFolder, allFiles{i}, 'cluster.mat');
    plotResults = false;
    smoothMaps = true;
    numberOfClusters = 400;
    bdfFileName = strcat(inputFolder, allFiles{i});
    [ topographicMaps, segmentCenters, segmentBoundaries, activationPlot, EEG ] = ...
        demoGFP(bdfFileName, numberOfClusters, smoothMaps, plotResults,saveResults );
end

end

