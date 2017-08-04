function tf = isFunctionalTestCase(file)

%  Copyright 2013 The MathWorks, Inc.

tf = false;

try
    tree = mtree(file, '-file');
catch ex %#ok<NASGU>
    % The contract is that any file in which a valid mtree cannot be
    % constructed is not a functional test case. All functional test cases
    % must be subject to static analysis. Ignoring the MException ID in
    % this case is a considered deviation from typical best programming
    % practices.
    return
end
if isnull(tree)
    return
end
    
root = tree.root;
if ~root.iskind('FUNCTION')
    return
end

mainOutput = root.Outs;
if isnull(mainOutput)
    return
end

outputExpressions = mtfind(tree, 'SameID', mainOutput);
indices = outputExpressions.indices;
% Work through the  array backwards, looking at the last expression with
% the variable and ignoring the first which is the variable listed in the
% main function output list.
for idx = fliplr(indices(2:end))
    thisOutput = tree.select(idx);
    parent = thisOutput.Parent;
    if ~iskind(parent, 'EQUALS')
        continue;
    end
    
    % Now that we have found the last assignment into the output variable,
    % this is our last loop iteration.
    expression = parent.Right;
    if ~iskind(expression, 'CALL')
        break;
    end
    
    functionCall = expression.Left;
    if strcmp(functionCall.string, 'functiontests')
        tf = true;
    end
    break;
end
    
    
        





