function tf = hasMissingVal(v)
%HASMISSINGVAL Identify rows of an array that have missing values.
%    TF = hasMissingVal(X) returns a logical vector with one value per row of
%    X, indicating whether any value in that row is missing.  Missing value
%    indicators are NaN for floating point types, "<undefined>" for categorical
%    types, empty for cell arrays of strings, or entirely blank for character
%    arrays.

%   Copyright 2012 The MathWorks, Inc.

v = v(:,:);

if isfloat(v)
    tf = any(isnan(v),2);
elseif isa(v,'categorical')
    tf = any(isundefined(v),2);
elseif iscellstr(v)
    tf = any(cellfun('isempty',v),2);
elseif ischar(v)
    tf = all(v == ' ',2);
else % including integers
    tf = false(size(v,1),1);
end
