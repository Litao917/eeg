function vars = container2vars(c)
%CONTAINER2VARS Convert cell or structure array to table's internal representation.

%   Copyright 2012 The MathWorks, Inc.

haveCell = iscell(c);
if haveCell
    nvars = size(c,2);
else
    s = c;
    fnames = fieldnames(s);
    nvars = length(fnames);
end

vars = cell(1,nvars);
for j = 1:nvars
    if haveCell
        cj = c(:,j);
    else % have structure
        cj = {s.(fnames{j})}';
    end
    if isempty(cj) % prevent iscellstr from catching these
        % give these the right number of rows, but no columns
        vars{j} = zeros(size(cj,1),0);
    elseif iscellstr(cj)
        % Prevent a cellstr that happens to have all the same length strings,
        % e.g., datestrs, from being converted into a char matrix.
        vars{j} = cj;
    elseif any(cellfun(@(x)size(x,1),cj(:)) ~= 1)
        % If the cells don't all have one row, we won't be able to
        % concatenate them and preserve rows, leave it as is.
        vars{j} = cj;
    elseif isscalar(cj)
        % If there's only one cell, the concatenation below will never fail, so
        % check to see if the value can be concatenated with itself.  If that
        % fails, assume that the value would not support supscripting, and
        % leave it in a cell.
        vars{j} = cj{1};
        try
            [vars{j}; vars{j}];
        catch ME %#ok<NASGU>
            % Among other things, a scalar function handle ends up here
            vars{j} = cj;
        end
    else
        % Concatenate cell contents into a homogeneous array (if all cells
        % of cj contain "atomic" values), a cell array (if all cells of cj
        % contain cells), or an object array (if all the cells of cj
        % contain objects).  The result may have multiple columns or pages
        % if the cell contents did, but each row will correspond to a
        % "row" (i.e., element) of S.  If that fails, either the values
        % are heterogeneous, or they would not support subscripting, so
        % leave them in cells.
        try
            vars_j = cell(1,size(cj,2));
            % Concatenate rows first
            for i = 1:size(cj,2), vars_j{i} = cat(1,cj{:,i}); end
            % Now concatenate multiple columns into a matrix
            vars{j} = cat(2,vars_j{:});
        catch ME %#ok<NASGU>
            % Amng other things, a column of function handles ends up here
            vars{j} = cj;
        end
    end
end
