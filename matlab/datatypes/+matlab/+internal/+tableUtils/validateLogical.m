function paramVal = validateLogical(paramVal,paramName)
%VALIDATELOGICAL Validate a scalar logical input.

%   Copyright 2012 The MathWorks, Inc.

if isscalar(paramVal)
    if islogical(paramVal)
        % leave it alone
    elseif isnumeric(paramVal)
        paramVal = logical(paramVal);
    end
else
    error(message('MATLAB:table:InvalidLogicalVal', paramName));
end
end % function


