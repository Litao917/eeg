function [ microstates ] = describeMicrostates( EEG )
%DESCRIBEMICROSTATES Summary of this function goes here
%   Detailed explanation goes here

EEG = removeNonEeg(EEG);
%maybe add the filter back in
%EEG.data = eegfilt(EEG.data, EEG.srate , 1, 125, size(EEG.data,2),
%3*EEG.srate, 0, 'fir1', 0);

[gmd] = double(globalMapDissimilarity(EEG));
filterSize = int32(EEG.srate/150);
filterVector = (1/double(filterSize))*ones(1,filterSize);
filtGmd = filtfilt(filterVector,1,gmd);
[localMinima, segmentCenters] = findpeaks(1-filtGmd);
[localMaxima, segmentBoundaries] = findpeaks(filtGmd);

smoothEEG = EEG;
for i = 1:size(EEG.data,1)
        smoothEEG.data(i,:) = filtfilt(filterVector,1,double(EEG.data(i,:)));
end
mapSegments = ones(size(EEG.data,1),0);
numberOfSegments = size(segmentCenters, 2);
for i = 1:numberOfSegments
        map = smoothEEG.data(:, segmentCenters(i));
            map = map - mean(map);
                mapSegments(:, i) = map;
end

microstates.centerGmds = 1-localMinima;
microstates.boundaryGmds = localMaxima;
microstates.centerXs = segmentCenters;
microstates.boundaryXs = segmentBoundaries;
microstates.centerData = mapSegments;

end

