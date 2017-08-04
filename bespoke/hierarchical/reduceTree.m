function [ newLinkage numberedBranchContents] = reduceTree( largeLinkage, newSize )
%REDUCETREE Reduces a linkage to the desired number of leaves
%   Condenses the closest links into single leaves, which permits plotting 
%   of large linkages and examination of their overall shape.  largeLinkage
%   is the inputLinkage, and newSize is the desired number of leaves in the
%   smaller linkage.  newLinkage is the resulting linkage, and
%   numberedBranchContents is a cell array containing integers.  The index
%   of the cell array corresponds to the branch number of the new linkage
%   (visible with plot(phytree(linkage), 'showlabels', 'true'), and the
%   contents of each array describes the leaves in the original tree.

numberedBranchContents = cell(1,size(largeLinkage,1));
for i = 1:length(numberedBranchContents)
    for j = 1:2
        if(largeLinkage(i,j) <= size(largeLinkage,1)+1)
            numberedBranchContents{i} = [numberedBranchContents{i} largeLinkage(i,j)];
        end
    end
end
newLinkage = largeLinkage;
endIndex = size(newLinkage,1);
startIndex = endIndex - newSize + 2;
sizeReduction = size(newLinkage,1)-newSize;
eliminated = NaN(1, size(newLinkage,1)+1-newSize);
elimCounter = 1;
%   #replace lowest merges, which are arranged in ascending order
for i = 1:startIndex-1
    [row, col] = find(newLinkage(:,1:2) == i + size(newLinkage,1)+1);
    newLinkage(row, col) = newLinkage(i,1);
        numberedBranchContents{row} = [numberedBranchContents{row} numberedBranchContents{i}];
    eliminated(elimCounter) = newLinkage(i,2);
    elimCounter= elimCounter + 1;
end
%   #match old leaf indices to new indices
oldLeaves = 1:endIndex+1;
newLeaves = NaN(1,endIndex+1);
newCounter = 1;
for dualIndex = 1:endIndex+1
    if(length(find(eliminated == oldLeaves(dualIndex))) == 0)
        newLeaves(dualIndex) = newCounter;
        newCounter = newCounter + 1;
    end
end
%   #re-label leaves and nodes
for i = startIndex:size(newLinkage,1)
    for j = 1:2
        if(newLinkage(i,j) > size(newLinkage,1)+1)
            newLinkage(i,j)=newLinkage(i,j) - 2*(1 + sizeReduction);
        else
            oldLeaf = find(oldLeaves == newLinkage(i,j));
            newLeaf = newLeaves(oldLeaf);
            newLinkage(i,j) = newLeaf;
        end
    end
end

%   #trim
newLinkage = newLinkage(startIndex:endIndex,:);
numberedBranchContents = numberedBranchContents(startIndex:endIndex);

end

