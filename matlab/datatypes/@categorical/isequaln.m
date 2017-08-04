function t = isequaln(varargin)
%ISEQUALN True if categorical arrays are equal, treating undefined elements as equal.
%   TF = ISEQUALN(A,B) returns logical 1 (true) if the categorical arrays A and
%   B are the same size and contain the same values or corresponding undefined
%   elements, and logical 0 (false) otherwise.  Either A or B may also be a cell
%   array of strings.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the test is performed by comparing the
%   category names of each pair of elements.
%
%   TF = ISEQUALN(A,B,C,...) returns logical 1 (true) if all the input arguments
%   are equal.
%
%   Use ISEQUAL to treat undefined elements as unequal.
%
%   See also ISEQUAL, EQ, CATEGORIES.

%   Copyright 2013 The MathWorks, Inc.

import matlab.internal.tableUtils.isStrings

narginchk(2,Inf);

a = varargin{1};
if isa(a,'categorical')
    % Strings will be converted to be "like" a.
else
    % Find the first "real" categorical as a prototype for converting strings.
    prototype = varargin{find(cellfun(@(x)isa(x,'categorical'),varargin),1,'first')};
    if isStrings(a)
        a = strings2categorical(a,prototype);
    else
        t = false; return
    end
end

isOrdinal = a.isOrdinal;
anames = a.categoryNames;
acodes = a.codes;

for i = 2:nargin
    b = varargin{i};
    
    if isa(b,'categorical')
        if b.isOrdinal ~= isOrdinal
            t = false; return
        elseif isequal(b.categoryNames,anames)
            bcodes = b.codes;
        elseif ~isOrdinal
            % Get a's codes for b's data, ignoring protectedness.
            bcodes = convertCodes(b.codes,b.categoryNames,anames);
        else
            t = false; return
        end
    elseif isStrings(b)
        [ib,ub] = strings2codes(b);
        bcodes = convertCodes(ib,ub,anames);
    else
        t = false; return
    end
    
    % Undefined elements in a will match undefined elements in b, both codes are 0
    t = isequal(bcodes,acodes);
    
    if ~t, break; end
end
