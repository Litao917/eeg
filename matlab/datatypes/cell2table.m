function t = cell2table(c,varargin)
%CELL2TABLE Convert cell array to table.
%   T = CELL2TABLE(C) converts the M-by-N cell array C to an M-by-N table T.
%   CELL2TABLE vertically concatenates the contents of the cells in each column
%   of C to create each variable in T, with one exception: if a column of C
%   contains strings, then the corresponding variable in T is a cell array of
%   strings.
%
%   T = CELL2TABLE(C, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in C are converted.
%
%      'VariableNames'  A cell array of strings containing variable names for
%                       T.  The names must be valid MATLAB identifiers, and must
%                       be unique.
%      'RowNames'       A cell array of strings containing row names for T.
%                       The names need not be valid MATLAB identifiers, but
%                       must be unique.
%
%   See also TABLE2CELL, ARRAY2TABLE, STRUCT2TABLE, TABLE.

%   Copyright 2012 The MathWorks, Inc.

if ~iscell(c) || ~ismatrix(c)
    error(message('MATLAB:cell2table:NDCell'));
end
[nrows,ncols] = size(c);

pnames = {'VariableNames' 'RowNames'};
dflts =  {            []         [] };
[varnames,rownames,supplied] ...
    = matlab.internal.table.parseArgs(pnames, dflts, varargin{:});

% Each column of C becomes a variable in D
nvars = ncols;
vars = matlab.internal.table.container2vars(c);

if supplied.VariableNames
    haveVarNames = true;
else
    baseName = inputname(1);
    if isempty(baseName) || (nvars == 0)
        haveVarNames = false;
    else
        if size(c,2) == 1
            varnames = {baseName};
        else
            varnames = matlab.internal.table.numberedNames(baseName,1:nvars);
        end
        haveVarNames = true;
    end
end

if isempty(vars) % creating a table with no variables
    % Give the output table the same number of rows as the input cell ...
    if supplied.RowNames % ... using either the supplied row names
        t = table('RowNames',rownames);
        if height(t) ~= nrows % let table validate rownames first, then check its size
            error(message('MATLAB:table:IncorrectNumberOfRowNames'));
        end
    else            % ... or by tricking the constructor
        dummyNames = matlab.internal.table.dfltRowNames(1:nrows);
        t = table('RowNames',dummyNames);
        if supplied.VariableNames, t.Properties.VariableNames = varnames; end
        t.Properties.RowNames = {};
    end
else
    dummyNames = matlab.internal.table.dfltVarNames(1:nvars);
    t = table.fromScalarStruct(cell2struct(vars,dummyNames,2)); % cell -> scalarStruct -> table
    if haveVarNames, t.Properties.VariableNames = varnames; end
    if supplied.RowNames, t.Properties.RowNames = rownames; end
end
