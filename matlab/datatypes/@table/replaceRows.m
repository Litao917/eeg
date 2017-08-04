function t = replaceRows(t,rowIndices,c)
%REPLACEROW Assign one or more table rows from a 1-by- cell vector.

%   Copyright 2012 The MathWorks, Inc.

t_data = t.data;
for j = 1:t.nvars
    var_j = t_data{j};
    % The size of the RHS has to match what it's going into.
    sizeLHS = size(var_j); sizeLHS(1) = 1;
    if ~isequal(sizeLHS, size(c{j}))
        error(message('MATLAB:table:AssignmentDimensionMismatch', t.varnames{varIndices(j)}));
    end
    try %#ok<ALIGN>
        var_j(rowIndices,:) = c{j}(:,:);
    catch ME, throw(ME); end
    % No need to check for size change, RHS and LHS are identical sizes.
    t_data{j} = var_j;
end
t.data = t_data;
