function [ output_args ] = lookAtHursts( input_args )
%LOOKATHURSTS Summary of this function goes here
%   Detailed explanation goes here

antChans = antChannelLocs();
folder = fileparts(which('lookAtHursts'));

    load(fullfile(folder,'hurst.mat'));

% siftObject=load(fullfile(folder,'qualityReport1.mat'));
allFilenames = getRobiDataFiles();

eegCounter = 1;
tic;
for fileIndex = 1:length(allFilenames)
  tic;
  
  % for fileIndex = 1:length(siftObject.quality.metrics)
  %   if(siftObject.quality.metrics(fileIndex) > 0)
  %     filename = siftObject.quality.allFilenames{fileIndex};
  filename = allFilenames{fileIndex};
  alreadyDone = strcmp({eegs.filename}, filename);
  if(~any(alreadyDone))
    eeg = openEeg(filename);
    eeg = remontage(eeg);
    minutes = 3;
    chunkSize = 2048 * 60 * minutes;
    chunkCount = floor(size(eeg,1) / chunkSize);
    if(chunkCount > 0)
      hurstSummary.filename = filename;
      disp(filename);
      chunks = struct();
      hurstSummary.sampleRate = 2048;
      hurstSummary.filterBottom = 0.5;
      hurstSummary.filterTop = 40;
      channelCount = size(eeg,2);
      channels = struct();
      for chanIndex = 1:channelCount
        channels(chanIndex).label = antChans{chanIndex};        
        for chunkIndex = 1:chunkCount
          chunk = struct();
          %         for chunkIndex = 1:2
          chunkData = eeg(chunkSize*(chunkIndex-1)+1:chunkSize*chunkIndex, chanIndex);
          chunk.detrendHurst = hurst(chunkData);
          chunk.oldHurst = genhurst(chunkData);
          filterData = filterFft(chunkData, hurstSummary.sampleRate, hurstSummary.filterBottom, hurstSummary.filterTop);
          [chunk.filterHurst, chunk.filterHurstPoints] = hurst(filterData);
          chunk.filterOldHurst = genhurst(filterData);
          disp(sprintf('%s[%d]: %f (filt: %f); detrend: %f (filt: %f)', channels(chanIndex).label, chunkIndex, ...
            chunk.oldHurst, chunk.filterOldHurst, chunk.detrendHurst, chunk.filterHurst));
          % disp(sprintf('%s end: %f (%f)', channel.label, channel.endHurst, channel.filterEndHurst));
          channels(chanIndex).chunks(chunkIndex) = chunk;
        end
      end
      hurstSummary.channels = channels;
      eegs(eegCounter) = hurstSummary;
      eegCounter = eegCounter + 1;
      save(fullfile(folder,'hurst.mat'), 'eegs');
      disp(sprintf('finished with file %d of %d', fileIndex, length(allFilenames)));
      toc;
    else
      disp(sprintf('too short, skipping: %s', filename));
    end
    %   end
  end
end
disp('all files processed');
toc;
end

