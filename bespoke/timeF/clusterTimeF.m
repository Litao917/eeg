function [ mappedX ] = clusterTimeF(varargin)
%BATCHPROCESSTIMEF Summary of this function goes here
%   Detailed explanation goes here
 
if(nargin > 0)
    if(iscell(varargin{1}))        
        fullRecord = varargin{1};
    end
else
    load(strcat('/home/data/EEG/processed/', 'timeFreqDecomp.mat'));
end

[ant1 ant2 ton1 ton2] = sortFiles(fullRecord);
top

allFiles = ant1;

data = [];
for j = 1:length(fullRecord)
    name = fullRecord{j}.file.filename;
    for i = 1:length(allFiles)
        if(strcmp(name, allFiles{i}))            
            b = fullRecord{j}.timeF;
            
            subtract = false;
            if(subtract)
            % subtraction
            for k = 1:length(ant2);
                name2 = ant2{k};
                if(strncmp(name, name2, 5))
                    for m = 1:length(fullRecord)
                        if(strcmp(name2, fullRecord{m}.file.filename))
                            cm = fullRecord{m}.timeF;
                            for n = 1:size(cm, 2)
                                bn = b(n).ersp;
                                cn = cm(n).ersp;
                                dn = cn - bn;
                                b(n).ersp = dn;
                            end
                        end
                    end
                end
            end
            end
            %
            
            row = [];
            for k = 1:length(b);
                row = [row, reshape(b(k).ersp, 1, [])];
            end
            data(end+1,:) = row;
        end
    end
end
%     a = fullRecord{i};
%     name = a.file.filename;
%     if(length(strfind(name, 'ANT')) > 0)
%         %debug
%         display(name);
%         %end debug
%         b = a.timeF;
%         row = [];
%         for(j = 1:length(b));
%             row = [row, reshape(b(j).ersp, 1, [])];
%         end
%         data(end+1,:) = row;
%     end
% end


Z = linkage(data, 'average', 'euclidean');
% cutoff = 1.15373798091; 
% cz = cluster(Z, 'cutoff', cutoff);

% ck = kmeans(data, 4);

figure;

% mappedX = tsne(data, [], 2, min(100, size(data,1)), 30);
[mappedX, mapping] = pca(data, 6);
gz = garlicCluster(Z, .1, .6);
gscatter(mappedX(:,1), mappedX(:,2), gz, [0 0 1; 1 0 0; 0 .5 0], 'xo^');
% gz = garlicCluster(Z, .1, .3);
% gscatter(mappedX(:,1), mappedX(:,2), gz, [0 0 1; 0 0 0; 1 0 0; 0 .5 0;.8 0 .8], 'xvo^s');


clusterSizes = tabulate(gz);
numberOfClusters = size(clusterSizes,1);
erspSums = cell(0);
protoErsp = fullRecord{1}.timeF.ersp;
erspRowCount = size(protoErsp, 1);
erspColumnCount = size(protoErsp, 2);
for i = 1:numberOfClusters
    erspSums{i} = zeros(erspRowCount, erspColumnCount);
end
for i = 1:length(allFiles)
    for j = 1:length(fullRecord)
        if(strcmp(allFiles{i}, fullRecord{j}.file.filename))
            tempErsp =  fullRecord{1}.timeF.ersp;
            tempErsp = db2mag(tempErsp);
            clusterNumber = gz(i) + 1;
             erspSums{clusterNumber} = erspSums{clusterNumber} + tempErsp;
%            erspSums{clusterNumber} = erspSums{clusterNumber} .* tempErsp;
        end
    end
end
for i = 1:numberOfClusters
     erspSums{i} = erspSums{i} / clusterSizes(i, 2);
%     erspSums{i} = nthroot( erspSums{i}, clusterSizes(i, 2));
end


[coeff,score] = pca(data, 6);
[icasig, A, W] = fastica(data);

downsampled = zeros(size(data,1),size(data,2)/2);
for i = 1:size(downsampled,1)
    row = data(i,:);
    downRow = zeros(1, length(row)/2);
    for j = 1:length(downRow)
        downRow(j) = (row(j*2)+row(j*2-1))/2;
    end
    downsampled(i,:)=downRow;
end

covariance = cov(downsampled);
tic;
eigen = eig(covariance);
toc;
save('eigen.mat');

end
 


