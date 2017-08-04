function [ output_args ] = analyzeCorrelations( inputs )
%ANALYZECORRELATIONS Summary of this function goes here
%   Detailed explanation goes here

root = '/home/data/EEG/processed/timeFCorrelations';

hardCodeX = 6;
hardCodeY = 133;
hardCodeChannel = 'T7';

subFolders = dir(root);

pSums = zeros(31,128,24,200);
rSums = zeros(31,128,24,200);


for folderNumber = 1:length(subFolders)
  if(exist('allFiles'))
    allFiles(1:end) = [];
  end
  candidate = fullfile(root,subFolders(folderNumber).name);
  if(exist(candidate) == 7 & subFolders(folderNumber).name ~= '.')
    disp(subFolders(folderNumber).name);

    %folder = '/home/data/EEG/processed/timeFCorrelations/ant1e44';
    folder = candidate;
    files = dir(folder);
    for fileNumber = length(files):-1:1
      if(files(fileNumber).name(1) == '.')
        files(fileNumber) = [];
      end
    end
    
    for fileNumber = 1:length(files)
      load(fullfile(folder, files(fileNumber).name));
      if(~exist('allFiles'))
        allFiles = output;
      else
        allFiles(end+1) = output;
      end
      if(exist('checkLength'))
        if(checkLength ~= length(output.correlations))
          error('unexpected length variation');
        end
      else
        checkLength = length(output.correlations);
      end      
      if(fileNumber == 1)
        minP = NaN(1, length(output.correlations));
        minChan = cell(1, length(minP));
        minChanPlot = [];
        minR = zeros(1, length(minP));
        minX = zeros(1, length(minP));
        minY = zeros(1, length(minP));
        varNames = cell(1, length(output.correlations));
        for i = 1:length(varNames)
          varNames{i} = output.correlations(i).name;
        end
      end
      for variableNumber = 1:length(output.correlations)
        correlation = output.correlations(variableNumber);
        for x = 1:size(correlation.P, 1)
          for y = 1:size(correlation.P, 2)
            pSums(fileNumber, variableNumber, x, y) = ...
              pSums(fileNumber, variableNumber, x, y) + ...
              log(output.correlations(variableNumber).P(x,y));
            rSums(fileNumber, variableNumber, x, y) = ...
              rSums(fileNumber, variableNumber, x, y) + ...
              output.correlations(variableNumber).R(x,y);
          end
        end
        if(length(correlation.P > 0))
          minP(variableNumber);
          if(exist('hardCodeX'))
            minX(variableNumber) = hardCodeX;
            minY(variableNumber) = hardCodeY;
            minP(variableNumber) = correlation.P(hardCodeX,hardCodeY);
            minR(variableNumber) = correlation.R(hardCodeX,hardCodeY);
            minChan{variableNumber} = hardCodeChannel;            
          else            
            for x = 1:size(correlation.P, 1)
              for y = 1:size(correlation.P, 2)
                if(~isnan(correlation.P(x,y)))
                  if(isnan(minP(variableNumber)) | correlation.P(x,y) < minP(variableNumber))
                    minP(variableNumber) = correlation.P(x,y);
                    minR(variableNumber) = correlation.R(x,y);
                    minX(variableNumber) = x;
                    minY(variableNumber) = y;
                    minChan{variableNumber} = output.channel;
                  end
                end
              end
            end
          end
        end
      end
    end
    if(~isnan(min(min([output.correlations.P]))))
      labels = {allFiles.channel};
      chanlocs = getChanlocs(labels);
      for i = 1:length(minP)
        if(~isnan(minP(i)))
          disp(sprintf('%s (%s): %f', varNames{i}, minChan{i}, ...
            log10(minP(i))));
        end
      end
      plotVar = 'lec_caps';
      index = find(strcmp({allFiles(1).correlations.name}, plotVar));
      disp(sprintf('min x: %f', minX(index)));
      disp(sprintf('min y: %f', minY(index)));
      
      slashes = strfind(folder, '/');
      folderName = folder(slashes(end) + 1: end);
      mapNumber = find(strcmp({allFiles.channel}, minChan(index)));
      
      figure;
      map = allFiles(mapNumber).correlations(index).P;
      htmap = heatmap(map);%, [-500:500:1500], [0:5:50], 0);
      title(sprintf('%s (%s) P', folderName, minChan{index}));
      colormap(jet);
      
      figure;
      mapR = allFiles(mapNumber).correlations(index).R;
      htmap = heatmap(mapR);%, [-500:500:1500], [0:5:50], 0);
      title(sprintf('%s (%s) R', folderName, minChan{index}));
      colormap(jet);
      
      %debug
      figure;
      hold on;
%       for i = 1:size(mapR, 1)
%         plot(mapR(i, :));
%       end
        plot(mapR(6, :));
      %end debug
      
      data = zeros(1, length(allFiles));
      for i = 1:length(data)
        data(i) = allFiles(i).correlations(index).R(minX(index),minY(index));
      end
      logData = log10(data);
      figure;
      topoplot(data, chanlocs);
      title(sprintf('%s (%d,%d) R', folderName, minX(index), minY(index)));
    end
  end
  
end
minSumChan = min(pSums);
minStep = squeeze(minSumChan(1,index,:,:));
absoluteMin = min(min(minStep));

index1 = find(pSums == absoluteMin);
[a b c d] = ind2sub([size(pSums)], index1);
tilefigs;
end

