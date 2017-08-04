function [bcodes,bnames] = convertCodes(bcodes,bnames,anames,aprotect,bprotect)
%CONVERTCODES Translate one categorical array's data to another's categories.

%   Copyright 2013 The MathWorks, Inc.

if nargin < 5
    aprotect = false;
    bprotect = false;
end

anames = anames(:);

if ischar(bnames)
    ia = find(strcmp(bnames,anames));
    if isempty(ia);
        if aprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
        bnames = [anames; bnames];
        bcodes = length(bnames);
    else
        bnames = anames;
        bcodes = ia;
    end

else % iscellstr(bnames)
    bnames = bnames(:);
    
    % Get a's codes for b's data.  Any elements of b that do not match a category of
    % a are assigned codes beyond a's range.
    [tf,ia] = ismember(bnames,anames);
    b2a = zeros(1,length(bnames)+1,categorical.codesClass);
    b2a(2:end) = ia;
    
    % a has more categories than b
    if length(ia(ia>0)) < length(anames)
        % If b is protected and a has more categories, can't convert.
        if bprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
    end
    
    % b has more categories than a
    if ~all(tf)
        % If a is protected and b has more categories, can't convert.
        if aprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
        ib = find(~tf(:));
        if length(anames) + length(ib) > categorical.maxNumCategories
            throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
        end
        b2a(ib+1) = length(anames) + (1:length(ib));
        bnames = [anames; bnames(ib)];
    else
        bnames = anames;
    end
    bcodes = reshape(b2a(bcodes+1),size(bcodes));
end
