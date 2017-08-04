function [tabulation, sequence] = summarizeEvents(EEG)

    types = [EEG.event.type];
    latency = [EEG.event.latency];
    duration = diff(latency);
    duration(end+1)=EEG.pnts-latency(end);
    
    sequence = [types; duration]';
    tabulation = sortrows(tabulate(types),2);
    empty = find(tabulation(:,2)==0);
    tabulation(empty, :) = [];
    
    for i = 1:size(tabulation, 1)
        value = tabulation(i, 1);
        indices = find(types == value);
        meanDuration = mean(duration(indices));
        stdDuration = std(duration(indices));
        tabulation(i,3) = meanDuration;
        tabulation(i,4) = stdDuration;
    end
    

    
    tabulation = array2table(tabulation, 'VariableNames', {'type', 'occurences', 'durationMean', 'durationStd'});

end
