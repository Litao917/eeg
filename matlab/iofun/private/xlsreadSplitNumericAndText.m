function [numericData, textData] = xlsreadSplitNumericAndText(data)
    % xlsreadSplitNumericAndText parses raw data into numeric and text arrays.
    %   [numericData, textData] = xlsreadSplitNumericAndText(DATA) takes cell
    %   array DATA from spreadsheet and returns a double array numericData and
    %   a cell string array textData.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.

    %   Copyright 1984-2012 The MathWorks, Inc.

    
    % ensure data is in cell array
    if ischar(data)
        data = cellstr(data);
    elseif isnumeric(data) || islogical(data)
        data = num2cell(data);
    end
    
    % Check if raw data is empty
    if isempty(data)
        % Abort when all data cells are empty.
        textData = {};
        numericData = [];
        return
    end
    
    % Initialize textData as an empty cellstr of the right size.
    textData = cell(size(data));
    textData(:) = {''};
    
    % Find non-numeric entries in data cell array
    isTextMask = cellfun('isclass',data,'char');
    
    % Place text cells in text array
    if any(isTextMask(:))
        textData(isTextMask) = data(isTextMask);
    else
        textData = {};
    end
    % Excel returns COM errors when it has a #N/A field.
    textData = strrep(textData,'ActiveX VT_ERROR: ','#N/A');
    
    % Trim the leading and trailing empties from textData
    emptyTextMask = cellfun('isempty', textData);
    textData = filterDataUsingMask(textData, emptyTextMask);
    
    % place NaN in empty numeric cells
    if any(isTextMask(:))
        data(isTextMask)={NaN};
    end
    
    % Find non-numeric entries in data cell array
    isLogicalMask = cellfun('islogical',data);

    % Convert cell array to numeric array through concatenating columns then
    % rows.
    cols = size(data,2);
    tempDataColumnCell = cell(1,cols);
    % Concatenate each column first
    for n = 1:cols
        tempDataColumnCell{n} = cat(1, data{:,n});
    end
    % Now concatenate the single column of cells into a numeric array.
    numericData = cat(2, tempDataColumnCell{:});

    % Trim all-NaN leading and trailing rows and columns from numeric array
    isNaNMask = isnan(numericData);
    if all(isNaNMask(:))
        numericData = [];
    else
        [numericData, isNaNMask] = filterDataUsingMask(numericData, isNaNMask);
    end

    % Restore logical type if all values were logical.
    if any(isLogicalMask(:)) && ~any(isNaNMask(:))
        numericData = logical(numericData);
    end
    
    % Ensure numericArray is 0x0 empty.
    if isempty(numericData)
        numericData = [];
    end
end

%--------------------------------------------------------------------------
function  [row, col] = getCorner(mask, firstlast)
    isLast = strcmp(firstlast,'last');

    % Find first (or last) row that is not all true in the mask.
    row = find(~all(mask,2), 1, firstlast);
    if isempty(row)
        row = emptyCase(isLast, size(mask,1));
    end
    
    % Find first (or last) column that is not all true in the mask.
    col = find(~all(mask,1), 1, firstlast);
    % Find returns empty if there are no rows/columns that contain a false value.
    if isempty(col)
        col = emptyCase(isLast, size(mask,2));
    end    
end

%--------------------------------------------------------------------------
function [data, mask] = filterDataUsingMask(data, mask)
    [rowStart, colStart] = getCorner(mask, 'first');
    [rowEnd, colEnd] = getCorner(mask, 'last');
    data = data(rowStart:rowEnd, colStart:colEnd);
    mask = mask(rowStart:rowEnd, colStart:colEnd);
end

%--------------------------------------------------------------------------
function dim = emptyCase(isLast, dimSize)
    if isLast
        dim = dimSize;
    else
        dim = 1;
    end
end