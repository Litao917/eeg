function [ output_args ] = eventRelatedMicrostates( input_args )
%EVENTRELATEDMICROSTATES Summary of this function goes here
%   Detailed explanation goes here

preMills = -500;
postMills = 1000;

allClassesOfFiles = getAllBdfs;
allFiles = allClassesOfFiles.Flanker1; %ANT files only
refChan = int32(32);

dimensionReductionPath = fullfile(strcat(fileparts(which('eeglab')), '/../drtoolbox'));
addpath(genpath(dimensionReductionPath));

for i = 1:length(allFiles)
    path = allFiles{i};
    outputPath = strcat(path, 'microstateClusters.mat');
    if(~exist(outputPath))
        
        EEG = pop_readbdf(path, {}, 43, refChan, false);
        [tabulation, sequence] = summarizeEvents(EEG);
        mostCommonEvent = tabulation{end,1};
        mostCommonEventCount = tabulation{end,2};
        [ microstates ] = describeMicrostates( EEG );
        
        latencyIndices = ([EEG.event.type] == mostCommonEvent);
        latencies = [EEG.event.latency];
        latencies = latencies(latencyIndices);
        preFrames = (preMills * 0.001 * EEG.srate);
        postFrames = (postMills * 0.001 * EEG.srate);
        eventCenteredSeries = cell(0);
        %     sequentialSeries
        %     =
        %     zeros(size(microstates.centerData,
        %     1) + 1, 0);
        sequentialSeries = zeros(size(microstates.centerData, 1), 0);
        absoluteLatencies = zeros(1,0);
        %     microstates.centerXs(inWindow);
        %
        for j = 1:length(latencies)
            windowStart = latencies(j)+preFrames;
            windowEnd = latencies(j)+postFrames;
            inWindow = (windowStart <= microstates.centerXs)...
                & (microstates.centerXs <= windowEnd);
            chunk = [microstates.centerData(:, inWindow)];
            absoluteLatencies = [absoluteLatencies, microstates.centerXs(inWindow)];
            eventCenteredSeries{j} = chunk;
            sequentialSeries = [sequentialSeries(:, :) chunk(:, :)];
        end
        
        try
            mappedX1 = tsne(sequentialSeries', [], 2, 32, 30);
        catch error
            %oh well
        end
        
        Z1 = linkage(sequentialSeries', 'average', 'euclidean');
        c1 = cluster(Z1, 'maxclust', 26);
        
        save(outputPath);
        %
        % loopMax = size(d, 1);
        % %loopMax = 3;
        % for i = 1:loopMax
        %     colors = ones(1,length(mappedX));
        %     colors(1:i) = 2;
        %     colors(i) = 3;
        %     gscatter(mappedX(:,1), mappedX(:,2), colors,...
        %         [.8 .8 .8;.1 .1 .1; 1,0,0], '..o');
        %     print(strcat(folder, 'animation', sprintf('%05d',i), '.png'), '-dpng');
    end
end


end