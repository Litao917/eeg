function [ output_args ] = testHurst( input_args )
%TESTHURST Summary of this function goes here
%   Detailed explanation goes here

noiseGen = dsp.ColoredNoise;
pink = noiseGen.step;
brownNoiseGen = dsp.ColoredNoise('InverseFrequencyPower', 2);
brown = brownNoiseGen.step;
whiteNoiseGen = dsp.ColoredNoise('InverseFrequencyPower', 0);
white = whiteNoiseGen.step;

colors = [{[0 0 0]}, {[1 .5 .5]}, {[1 0 0]}];

figure;
hold on;
power = 20;
sampleCount = 2^power;
indices = 0:power-1;
plotX = 2.^indices;
noises = NaN(sampleCount, 3);
for i = 0:2
    noiseGen = dsp.ColoredNoise('InverseFrequencyPower', i, 'SamplesPerFrame', sampleCount);
    noise = noiseGen.step;
    noises(:,i+1) = noise;
    noiseFft = abs(fft(noise));
    noiseFft = noiseFft(1:length(noiseFft)/2);
    logFft = log(noiseFft);
    samples= NaN(1,length(plotX)-1);
    for j = 1:length(samples)
        samples(j) = mean(logFft(plotX(j):plotX(j+1)));
    end
    color = colors{i+1};
%     plot(noiseFft, 'color', color);
    plot(samples, 'color', color);
end

sums = NaN(size(noises,1),size(noises,2));
for j = 1:size(sums,2)
    sum = 0;
    for i = 1:size(sums,1)
        sum = sum + noises(i,j);
        sums(i,j)=sum;
    end
end

figure; hold on;
for i = 1:size(noises,2)
    theirHurst(i) = genhurst(sums(:,i)');
    [myHurst(i), points] = hurst(noises(:,i)');
    plot(log2(points(:,1)), log2(points(:,2)), 'color', colors{i});
    disp(sprintf('%d has a hurst exponent of: %f (or %f)', i-1, theirHurst(i), myHurst(i)));
end

% pinkFft = abs(fft(pink));
% pinkFft = pinkFft(1:length(pinkFft)/2);
% plot(pinkFft);


end

