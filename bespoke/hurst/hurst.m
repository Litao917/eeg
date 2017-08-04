function [ hurstExponent, points] = hurst( data )
%HURST Summary of this function goes here
%   Detailed explanation goes here
verbose = false;

max2Power = floor(log2(length(data)));
maxSamples = 1024;
% min2Power = max(max2Power -10, 1);
% pointCount = floor(log2(length(data))) - min2Power;
pointCount = floor(log2(length(data)));
points = NaN(pointCount, 2);
pointCounter = 1;
demeaned = data - mean(data);
sumData = cumsum(demeaned);
stepBase = 2;
% windowSize = pow2(min2Power);
windowSize = 2;
while(windowSize < length(sumData))
    if(verbose)
        fprintf(sprintf('\nwindow size: %d', windowSize));
    end
    windowStart = 1;
    counter = 1;
    errorSum = 0;
    resampleInterval = windowSize;
    if(length(sumData)/windowSize > maxSamples)
      resampleInterval = floor(length(sumData) / maxSamples);
    end
    while(windowStart + windowSize < length(sumData))
        window = sumData(windowStart:windowStart+windowSize-1);
        if(size(window,1)>size(window,2))
            window = window';
        end
        p = polyfit(1:length(window), window, 1);
        a = (1:length(window));
        a = a .* p(1);
        a = a + p(2);
        residual = window - a;
        rootMeanSquared = sqrt(sum(residual .* residual) / length(window));
        errorSum = errorSum + rootMeanSquared;
        counter = counter + 1;
        if(verbose)
            if(mod(counter,1000) == 0)
                fprintf('.');
                if(mod(counter,100000)==0)
                    fprintf(sprintf('\n%d', counter / 100000));
                end
            end
        end
        windowStart = windowStart + resampleInterval;
    end
    average = errorSum / (counter - 1);
    points(pointCounter, 1) = windowSize;
    points(pointCounter, 2) = average;
    pointCounter = pointCounter + 1;
    windowSize = windowSize * stepBase;
end
if(verbose)
    fprintf(sprintf('\n'));
end
logPoints = log2(points);
[rho, pValue] = corr(logPoints);
rSquared = rho(1,2) * rho(1,2);
minRSquared = .95;
while(rSquared < minRSquared & size(logPoints,1) > 5)
  p = polyfit(logPoints(:,1), logPoints(:,2), 1);
  a = (logPoints(:,1));
  a = a .* p(1);
  a = a + p(2);
  err = logPoints(:,2) - a;
  err = err .* err;
  maxErr = find(err==max(err));
  logPoints(maxErr,:) = [];
  [rho, pValue] = corr(logPoints);
  rSquared = rho(1,2) * rho(1,2);  
end
%points = logPoints;
hurstExponent = p(1);
end

