function [acodes,bcodes] = reconcileCategories(a,b,requireOrdinal)
%RECONCILECATEGORIES Utility for logical comparison of categorical arrays.

%   Copyright 2013 The MathWorks, Inc. 

import matlab.internal.tableUtils.isStrings

if isa(a,'categorical') && isa(b,'categorical')
    if requireOrdinal && (~a.isOrdinal || ~b.isOrdinal)
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    elseif a.isOrdinal ~= b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:OrdinalMismatchComparison'));
    end
    acodes = a.codes;
    if isequal(a.categoryNames,b.categoryNames)
        bcodes = b.codes;
    elseif a.isOrdinal % && b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidOrdinalComparison'));
    else
        bcodes = convertCodes(b.codes,b.categoryNames,a.categoryNames,a.isProtected,b.isProtected);
    end
    
elseif isStrings(b) % && isa(a,'categorical')
    if requireOrdinal && ~a.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    end
    acodes = a.codes;
    [ib,ub] = strings2codes(b);
    bcodes = convertCodes(ib,ub,a.categoryNames,a.isProtected,false);
    
elseif isStrings(a) % && isa(b,'categorical')
    if requireOrdinal && ~b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    end
    [ia,ua] = strings2codes(a);
    acodes = convertCodes(ia,ua,b.categoryNames,false,b.isProtected);
    bcodes = b.codes;

else
    throwAsCaller(msg2exception('MATLAB:categorical:InvalidComparisonTypes'));
end
