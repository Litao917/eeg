function y = defaultarrayLike(sz,~,x)
%DEFAULTARRAYLIKE Create a variable like x containing null values
%   Y = DEFAULTARRAYLIKE(SZ,'Like',X) returns a variable the same class as X,
%   with the specified size, containing default values.  The default value for
%   floating point types is NaN, in other cases the default value is the value
%   MATLAB uses by default to fill in unspecified elements on array expansion.
%
%      Array Class            Null Value
%      ---------------------------------------------
%      double, single         NaN
%      int8, ..., uint64      0
%      logical                false
%      categorical            <undefined>
%      char                   char(0)
%      cellstr                {''}
%      cell                   {[]}
%      other                  [MATLAB default value]

%   Copyright 2012-2013 The MathWorks, Inc.

n = sz(1); p = prod(sz(2:end));
if isfloat(x)
    y = nan(sz,'like',x);
elseif isnumeric(x)
    y = zeros(sz,'like',x);
elseif islogical(x)
    y = false(sz);
elseif ischar(x)
    y = repmat(char(0),sz);
elseif isa(x,'categorical')
    y = x(1:0);
    if min(n,p) > 0
        y(n,p) = categorical.undefLabel;
    end
    y = reshape(y,sz);
elseif iscell(x)
    if iscellstr(x)
        y = repmat({''},sz);
    else
        y = cell(sz);
    end
else
    % *** this will fail if x is empty
    y = x(1:0); y(n+1,p) = x(1); y = reshape(y(1:n,:),sz);
end
