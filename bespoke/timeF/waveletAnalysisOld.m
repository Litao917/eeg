function [ timeFrequencyDecomposition, data, frameNumbers ] = waveletAnalysis( EEG, waveletCycles, eventValue, channel, preMills, postMills )
%GETDATAAROUNDEVENT Summary of this function goes here
%   Detailed explanation goes here
 
argCounter = 2;
if(nargin < argCounter)
    waveletCycles = 0;
end
argCounter = argCounter+1;
if(nargin < argCounter)
    eventValue = 114;
end
argCounter = argCounter+1;
if(nargin < argCounter)
    channel = 31;
elseif(isstr(channel))
    channel = find(strcmp({EEG.chanlocs.labels}, channel));
end
argCounter = argCounter+1;
if(nargin < argCounter)
    preMills = 500;
end
argCounter = argCounter+1;
if(nargin < argCounter)
    postMills = 2500;
end
 
if(preMills < 0) preMills = -preMills;end
 
indices = find([EEG.event.type]== eventValue);
latencies = [EEG.event.latency];
eventCount = length(EEG.event);
eventLatencies = latencies(indices);
preFrames = (preMills * 0.001 * EEG.srate);
postFrames = (postMills * 0.001 * EEG.srate);
frameDuration = preFrames + postFrames + 1;
data = zeros(1, frameDuration * eventCount);
frameNumbers = int64(zeros(1, length(data)));
writeIndex = int64(1);
for i = 1:length(eventLatencies)
    readIndex = eventLatencies(i)-preFrames;
    if(readIndex > 0 && readIndex+frameDuration <= size(EEG.data, 2))
        nextData = EEG.data(channel, readIndex:(readIndex+frameDuration));
        data(writeIndex:(writeIndex+frameDuration)) = nextData;
        frameNumbers(writeIndex:writeIndex+frameDuration) = readIndex:readIndex+frameDuration;
    else
        data(end-frameDuration+1:end) = [];
        frameNumbers(end-frameDuration+1:end) = [];
    end
    writeIndex = writeIndex + frameDuration;
end
 
srate = EEG.srate;
tlimits = [-preMills, postMills];
figure;
[ersp,itc,powbase,times,freqs,erspboot,itcboot,itcphase] = ...
                 timef(data,frameDuration,tlimits,srate,waveletCycles,...
                 'plotersp', 'off', 'plotitc', 'off', 'plotphase', 'off');
timeFrequencyDecomposition.ersp = ersp;
timeFrequencyDecomposition.itc = itc;
timeFrequencyDecomposition.powbase = powbase;
timeFrequencyDecomposition.times = times;
timeFrequencyDecomposition.freqs = freqs;
timeFrequencyDecomposition.erspboot = erspboot;
timeFrequencyDecomposition.itcboot = itcboot;
timeFrequencyDecomposition.itcphase = itcphase;
end
 


