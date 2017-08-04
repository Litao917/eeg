function [rowIndices,numIndices,maxIndex,newNames] = getRowIndices(t,rowIndices,allowNew)
%GETROWINDICES Process string, logical, or numeric row indices in a table.

% getrowindices returns indices if given indices or names, but leaves logical
% or ':' subscripts as is.

%   Copyright 2012 The MathWorks, Inc.

if nargin < 3, allowNew = false; end
newNames = {};

% Translate row names into indices
if ischar(rowIndices)
    if strcmp(rowIndices, ':')
        % leave rowIndices as ':'
        numIndices = t.nrows;
        maxIndex = t.nrows;
    elseif size(rowIndices,1) == 1
        rowName = rowIndices;
        rowIndices = find(strcmp(rowName,t.rownames));
        if isempty(rowIndices)
            if allowNew
                rowIndices = t.nrows+1;
                newNames = {rowName};
            else
                error(message('MATLAB:table:UnrecognizedRowName', rowName));
            end
        end
        numIndices = 1;
        maxIndex = rowIndices;
    else
        error(message('MATLAB:table:InvalidRowName'));
    end
elseif iscellstr(rowIndices)
    rowNames = rowIndices;
    rowIndices = zeros(1,numel(rowIndices));
    maxIndex = t.nrows;
    for i = 1:numel(rowIndices)
        rowIndex = find(strcmp(rowNames{i},t.rownames));
        if isempty(rowIndex)
            if allowNew
                maxIndex = maxIndex+1;
                rowIndex = maxIndex;
                newNames{rowIndex-t.nrows,1} = rowNames{i}; %#ok<AGROW>
            else
                error(message('MATLAB:table:UnrecognizedRowName', rowNames{i}));
            end
        end
        rowIndices(i) = rowIndex;
    end
    numIndices = numel(rowIndices);
    maxIndex = max(rowIndices);
elseif isnumeric(rowIndices) || islogical(rowIndices)
    % leave the indices themselves alone
    if isnumeric(rowIndices)
        if any(isnan(rowIndices))
            error(message('MATLAB:badsubscript',getString(message('MATLAB:badsubscriptTextRange'))));
        end
        numIndices = numel(rowIndices);
        maxIndex = max(rowIndices(:));
    else
        numIndices = sum(rowIndices(:));
        maxIndex = find(rowIndices,1,'last');
    end
    if maxIndex > t.nrows
        if allowNew
            if ~isempty(t.rownames)
                % If the target table has row names, create default names
                % for the new rows, but make sure they don't conflict with
                % existing names.
                newNames = matlab.internal.table.dfltRowNames((t.nrows+1):maxIndex);
                newNames = matlab.lang.makeUniqueStrings(newNames,t.rownames,namelengthmax);
            end
        else
            error(message('MATLAB:table:RowIndexOutOfRange'));
        end
    end
else
    error(message('MATLAB:table:InvalidRowSubscript'));
end
rowIndices = rowIndices(:);
