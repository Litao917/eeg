function [ branches, oldLeafLabels ] = getSubBranches( originalLinkage, subBranchRoot, numberOfBranches, originalLeafLabels )
%GETSUBBRANCHES Gets one or more sub-branches of a linkage tree
%   "originalLinkage" is the input linkage data structure, an nx3 matrix 
%   created by the linkage() function.  "subBranchRoot" is the
%   label of the branch node to start including branches and leaves, with
%   1 being the lowest height branch and #leaves-1 being the original root.
%   "numberOfBranches" is the desired number of sub-branches, default=2.
%   "originalLeafLabels" is used for recursion, usually not passed by the
%   user.  "branches" is a cell array contaning the linkages of each
%   sub-branch, which can be a 0x3 array if the branch consists of only one
%   leaf.  "oldLeafLabels" is a cell array where each cell contains an
%   array of the integer labels of the leaves from the original linkage.
%   If you only call for one subBranch, return values will not be in cells.

%   One interesting note, you can get a sense of the shape of a phylogram
%   from a reduction.  The reduced tree will have sub-branches that are
%   spaced the same distance from the maximum node in the unreduced tree.
%   So a 100 leaf tree's node 86 is the same as a 200 leaf tree's node 186.

numberOfBigTreeLeaves = size(originalLinkage,1)+1;
if(nargin < 4)
    originalLeafLabels = 1:numberOfBigTreeLeaves;
end
if(nargin < 3)
    numberOfBranches = 2;
end
toAdd = [originalLinkage(subBranchRoot,:), subBranchRoot];
branches = [];
%populate the sub tree
while(size(toAdd,1) > 0)
    for j = 1:2
        currentNode = toAdd(1,j);
        if(currentNode > numberOfBigTreeLeaves)
            nextNode = currentNode - numberOfBigTreeLeaves;
            %newRowNumber = size(branches,1) + size(toAdd,1)+ 1;
            newRow = [originalLinkage(nextNode,:), nextNode];
            %newRow(j) = newRowNumber;
            toAdd(size(toAdd,1)+1,:) = newRow;
        end
    end
    branches(size(branches,1)+1,:) = toAdd(1,:);
    toAdd(1,:) = [];
end


branches = sortrows(branches,4);

%do calculations for re-indexing
numberOfSmallTreeLeaves = size(branches,1)+1;
branchDecrement = numberOfBigTreeLeaves-numberOfSmallTreeLeaves;
newIndices = NaN(1,numberOfSmallTreeLeaves);
newIndexCounter = 1;
for i = 1:numberOfBigTreeLeaves
    if(length(find(branches(:,1:2) == i)) > 0)
        newIndices(newIndexCounter) = i;
        newIndexCounter = newIndexCounter + 1;
    end
end


%re-index
oldLeafLabels=NaN(1,numberOfSmallTreeLeaves);
for i = 1:size(branches,1)
    for j = 1:2
        if(branches(i,j) > numberOfBigTreeLeaves) %node is branch
            seekBranch = branches(i,j)-numberOfBigTreeLeaves;
            branchRow = find(branches(:,4)==seekBranch);
            branches(i,j) = branchRow + size(branches,1)+1;
        else %node is leaf
            newIndex = find(newIndices == branches(i,j));
            oldLeafLabels(newIndex) = originalLeafLabels(branches(i,j));
            branches(i,j) = newIndex;
        end
    end
end
branches = branches(:,1:3);

%break into smaller branches with recursive calls
if(numberOfBranches > 1)
    totalBranches = cell(1, numberOfBranches);
    totalLeafLabels = cell(1, numberOfBranches);
    rootIndicies = zeros(1,numberOfBranches);
    for i = 1:numberOfBranches-1
        brokenRoot = size(branches,1) - i + 1;
        existingIndex = find(rootIndicies == brokenRoot);
        if(length(existingIndex) == 0)
            existingIndex = i+1;
        end
        rootIndicies(i) = branches(brokenRoot,1);
        rootIndicies(existingIndex) = branches(brokenRoot,2);
    end
    newLeafCount = size(branches,1)+1;
    for i = 1:numberOfBranches
        if(rootIndicies(i) > newLeafCount)
            subBranch = rootIndicies(i)-newLeafCount;
            [totalBranches{i}, totalLeafLabels{i}] = ...
                getSubBranches(branches,subBranch,1,oldLeafLabels);
        else
            totalBranches{i} = zeros(0,3);
            totalLeafLabels{i} = rootIndicies(i);
        end
    end
    branches = totalBranches;
    oldLeafLabels = totalLeafLabels;
end

end

