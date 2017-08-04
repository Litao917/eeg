function t = array2table(x,varargin)
%ARRAY2TABLE Convert matrix to table.
%   T = ARRAY2TABLE(A) converts the M-by-N array A to an M-by-N table T.
%   Each column of A becomes a variable in T.
%
%   NOTE:  A can be any type of array, including a cell array.  However, in that
%   case you probably want to use CELL2TABLE instead.  ARRAY2TABLE creates the
%   variables in T from each column of A.  If A is a cell array, ARRAY2TABLE
%   does not extract the contents of its cells -- T in this case is a table each
%   of whose variables is a column of cells.  To create a table from the
%   contents of the cells in A, use CELL2TABLE(A).
%
%   T = ARRAY2TABLE(X, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in X are converted.
%
%      'VariableNames'  A cell array of strings containing variable names for
%                       T.  The names must be valid MATLAB identifiers, and must
%                       be unique.
%      'RowNames'       A cell array of strings containing row names for T.  The
%                       names need not be valid MATLAB identifiers, but must be
%                       unique.
%
%   See also TABLE2ARRAY, CELL2TABLE, STRUCT2TABLE, TABLE.

%   Copyright 2012 The MathWorks, Inc.

if ~ismatrix(x)
    error(message('MATLAB:array2table:NDArray'));
end
[nrows,ncols] = size(x);

pnames = {'VariableNames' 'RowNames'};
dflts =  {            []         [] };
[varnames,rownames,supplied] ...
    = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

if supplied.VariableNames
    haveVarNames = true;
else
    baseName = inputname(1);
    nvars = size(x,2);
    if isempty(baseName) || (nvars == 0)
        haveVarNames = false;
    else
        if size(x,2) == 1
            varnames = {baseName};
        else
            varnames = matlab.internal.table.numberedNames(baseName,1:nvars);
        end
        haveVarNames = true;
    end
end

% Each column of X becomes a variable in T
vars = mat2cell(x,nrows,ones(1,ncols));

if isempty(vars) % creating a table with no variables
    % Give the output table the same number of rows as the input struct ...
    if supplied.RowNames % ... using either the supplied row names
        t = table('RowNames',rownames);
        if height(t) ~= nrows % let table validate rownames first, then check its size
            error(message('MATLAB:table:IncorrectNumberOfRowNames'));
        end
    else                 % ... or by tricking the constructor
        dummyNames = matlab.internal.table.dfltRowNames(nrows);
        t = table('RowNames',dummyNames);
        if supplied.VariableNames, t.Properties.VariableNames = varnames; end
        t.Properties.RowNames = {};
    end
else
    t = table(vars{:});
    if haveVarNames, t.Properties.VariableNames = varnames; end
    if supplied.RowNames, t.Properties.RowNames = rownames; end
end
