function branches = garlicCluster(tree, minPortion, maxPortion)
%GARLICCLUSTER Clusters a hierarchical tree, discarding the "skin" of
%sparse branches
%   Inputs are the data linkage, along with a minimum and maximum portion 
%   size; this will indirectly control the number of clusters that are 
%   output, but will also depend on the way the data is actually clustered.
%   So it's like smacking a bulb of garlic and pulling the cloves out.

if(nargin < 3)
    maxPortion = 0.3;
end
if(nargin < 2)
    minPortion = 0.01;
end
n = size(tree,1);
%append 2 columns; the first indicates the size of that branch, the second 
%the cluster it belongs to (0 means none)
tree = [tree zeros(n,2)];
for i = 1:n
    values = ones(1,2);
    for j = 1:2
        if(tree(i,j) > n+1)
            rowNumber = tree(i,j) - (n+1);
            values(j) = tree(rowNumber,4);
        end
    end
    tree(i,4) = sum(values);
end
clusterCounter = 1;
nR = 1/n;
for i = n:-1:1
    if(tree(i,5)==0)
        portion = tree(i,4)*nR;
        if(minPortion <= portion && portion <= maxPortion)
            todo = i;
            while(~isempty(todo))
                thisRow = todo(1);
                tree(thisRow, 5) = clusterCounter;
                for j = 1:2
                    if(tree(thisRow,j) > (n+1))
                        nextRow = tree(thisRow,j) - (n+1);
                        todo = [todo, nextRow];
                    end
                end
                todo(1) = [];
            end
            clusterCounter = clusterCounter + 1;
        end
    end
end
branches = zeros(size(tree,1)+1, 1);
for i = 1:size(tree,1)
    for j = 1:2
        branchNumber = tree(i,j);
        if(tree(i,j) <= length(branches))
            branches(branchNumber) = tree(i,5);
        end
    end
end

% branches(2:end) = tree(:,5)';
% branches(1) = branches(2);
end