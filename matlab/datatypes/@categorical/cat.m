function a = cat(dim,varargin)
%CAT Concatenate categorical arrays.
%   C = CAT(DIM, A, B, ...) concatenates the categorical arrays A, B, ...
%   along dimension DIM.  All inputs must have the same size except along
%   dimension DIM.  Any of A, B, ... may also be cell arrays of strings.
%
%   If all the input arrays are ordinal categorical arrays, they must have the
%   same sets of categories, including category order.  If none of the input
%   arrays are ordinal, they need not have the same sets of categories.  In this
%   case, C's categories are the union of the input array categories. However,
%   categorical arrays that are not ordinal but are protected may only be
%   concatenated with other arrays that have the same categories.
%
%   See also HORZCAT, VERTCAT.

%   Copyright 2006-2013 The MathWorks, Inc.

import matlab.internal.tableUtils.isStrings

a = varargin{1};
if isa(a,'categorical')
    % Strings will be converted to be "like" a.
    prototype = a;
else
    % Find the first "real" categorical as a prototype for converting strings.
    % This is expensive if nargin is large, so only do it if necessary.
    prototype = varargin{find(cellfun(@(x)isa(x,'categorical'),varargin),1,'first')};
    if ~isequal(a,[])
        if isStrings(a)
            a = strings2categorical(a,prototype);
        elseif iscell(a)
            error(message('MATLAB:categorical:cat:TypeMismatchCell'));
        else
            error(message('MATLAB:categorical:cat:TypeMismatch',class(a)));
        end
    end
end
% The inputs must be all ordinal or not, so need only save one setting.
isOrdinal = prototype.isOrdinal;

for i = 2:nargin-1
    b = varargin{i};

    % Accept [] as a valid "identity element" for either arg.
    if isequal(a,[])
        a = b;
        continue; % ignore a, but we may end up here again
    elseif isequal(b,[])
        continue; % completely ignore this input
    elseif ~isa(b,'categorical')
        if isStrings(b)
            b = strings2categorical(b,prototype);
        elseif iscell(b)
            error(message('MATLAB:categorical:cat:TypeMismatchCell'));
        else
            error(message('MATLAB:categorical:cat:TypeMismatch',class(b)));
        end
    elseif b.isOrdinal ~= isOrdinal
        error(message('MATLAB:categorical:OrdinalMismatchConcatenate'));
    end
    if isequal(a.categoryNames,b.categoryNames)
        bcodes = b.codes;
    elseif ~isOrdinal
        % Convert b to a's categories, possibly expanding the set of categories
        % if neither array is protected.
        [bcodes,a.categoryNames] = convertCodes(b.codes,b.categoryNames,a.categoryNames,a.isProtected,b.isProtected);
    else
        error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
    end
    a.isProtected = a.isProtected || b.isProtected;

    try
        a.codes = cat(dim, a.codes, bcodes);
    catch ME
        throw(ME);
    end
end
