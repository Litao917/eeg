function [ result ] = filterFft( X, samplesPerSecond, lowerBound, upperBound )
%FILTERFFT Summary of this function goes here
%   Detailed explanation goes here

fftX = fft(X);
low = length(X) / samplesPerSecond * lowerBound;
high = length(X) / samplesPerSecond * upperBound;
fftX(2:2+low) = 0;
fftX(end-low:end) = 0;
fftX(2+high:end-high) = 0;

result = ifft(fftX);

end

