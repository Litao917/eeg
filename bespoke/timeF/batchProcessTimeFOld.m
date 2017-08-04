function [ output_args ] = batchProcessTimeF( input_args )
%BATCHPROCESSTIMEF Summary of this function goes here
%   Detailed explanation goes here

allEvents = [];

eventFile = '/home/data/EEG/processed/eventData.mat';
%outputFilename = '/home/data/EEG/processed/timeF.mat';
if(exist(eventFile))
    load(eventFile);
end
% if(exist(outputFilename))
%     load(outputFilename);
% else
%    fullRecord = [];
% end

files = getAllBdfs;
allFiles = [files.Auditory1, files.Auditory2, files.Flanker1, files.Flanker2, files.PTSD];
for i = 1:length(allEvents)
    a = allEvents(i).tabulation;
    mostCommonEvents(i)=a{end, 1};
end

eventTable = tabulate(mostCommonEvents);
remove = eventTable(:,2)==0;
eventTable(remove,:) = [];

refChan = int32(32);
fileNumbers = zeros(1,length(mostCommonEvents));
% if(exist('fullRecord'))    
%     minI = length(fullRecord) + 1;
% else
%     fullRecord= [];
    minI = 1;
% end

% poolobj = gcp('nocreate');
% if(isempty(poolobj))    
%     % delete(poolobj);
%     parpool(16);
% end

for i = minI:length(mostCommonEvents)
    event = mostCommonEvents(i);
    [a fileA] = fileparts(allFiles{i});
    for j = 1:length(allEvents)
        [a fileB] = fileparts(allEvents(j).filename);
        if(strcmp(lower(fileB), lower(fileA)))
            fileNumbers(i) = j;
        end
    end
    j = fileNumbers(i);
    
    
    
    
    
    individualFolder = '/home/data/EEG/processed/timeF/';
    individualPrefix = strcat(individualFolder, fileA);
    
    existingFilenames = dir(individualFolder);
    
    fileExists = false;
    sourceFilename = '';
    for existingIndex = 1:length(existingFilenames)
        if(strfind(existingFilenames(existingIndex).name, fileA))
            fileExists = true;
            sourceFilename = strcat(individualFolder, existingFilenames(existingIndex).name);
        end
    end
    if(fileExists)
        %movefile(sourceFilename, individualFile);
    else
        
        
        
        
        
        %     display(strcat('processing file (', num2str(length(fullRecord))+1,...
        %         ') of (', num2str(length(mostCommonEvents)), ')'));
        display(strcat('processing file (', num2str(i),...
            ') of (', num2str(length(mostCommonEvents)), ')'));
        
        
        
        %a = tabulation{i};
        %    if(a{end,1} == mostCommonEvent)
        path = allFiles{i};
        EEG = pop_readbdf(path, {}, 43, refChan, false);
        data.file = path;
        data.event = mostCommonEvents(i);
        
        
        individualFile = strcat(individualFolder, fileA, '.timeFEvent', num2str(data.event), '.mat');
        
        
        
        orderedLabels = {EEG.chanlocs.labels};
        for k = 1:31
            %label = EEG.chanlocs(k).labels
            %data.channel(k).label = label;
            %             data.channel(k).timeF = waveletAnalysis(EEG, [2, 0.5],...
            %                 data.event, label);
            unorderedLabels{k} = orderedLabels{k};
            timeF(k) = waveletAnalysis(EEG, [2, 0.5],...
                data.event, unorderedLabels{k});
        end
        for k = 1:31
            data.channel(k).label = unorderedLabels{k};
            data.channel(k).timeF = timeF(k);
        end
        
        %        data.timeF = waveletAnalysis(EEG, [2, 0.5], data.event, 'Fz');
        %         if(length(fullRecord) == 0)
        %             fullRecord = data;
        %         else
        %             fullRecord(end+1) = data;
        %         end
        %         picName = strcat('E:\EEG\timeF\', files(i).filename, 'TimeF.png');
        %         print(picName, '-dpng');
        fclose('all');
        close all;
        %    end
        %         save(outputFilename, 'fullRecord');
        save(individualFile, 'data');
    end
    
end


end



