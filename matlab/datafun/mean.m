function y = mean(x,dim,flag)
%MEAN   Average or mean value.
%   S = MEAN(X) is the mean value of the elements in X
%   if X is a vector. For matrices, S is a row
%   vector containing the mean value of each column.
%   For N-D arrays, S is the mean value of the
%   elements along the first array dimension whose size
%   does not equal 1.
%   If X is floating point, that is double or single,
%   S has the same class as X. If X is of integer
%   class, S has class double.
%
%   MEAN(X,DIM) takes the mean along the dimension DIM
%   of X.
%
%   S = MEAN(X,'double') and S = MEAN(X,DIM,'double')
%   returns S in double, even if X is single.
%
%   S = MEAN(X,'native') and S = MEAN(X,DIM,'native')
%   returns S in the same class as X.
%
%   S = MEAN(X,'default') and S = MEAN(X,DIM,'default')
%   are equivalent to S = MEAN(X) and S = MEAN(X,DIM)
%   respectively.
%
%   Example: If X = [1 2 3; 3 3 6; 4 6 8; 4 7 7];
%
%   then mean(X,1) is [3.0000 4.5000 6.0000] and
%   mean(X,2) is [2.0000 4.0000 6.0000 6.0000].'
%
%   Class support for input X:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32,
%               int32, uint64, int64
%
%   See also MEDIAN, STD, MIN, MAX, VAR, COV, MODE.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin==2 && ischar(dim)
    flag = dim;
elseif nargin < 3
    flag = 'default';
end

if nargin == 1 || (nargin == 2 && ischar(dim))
    % preserve backward compatibility with 0x0 empty
    if isequal(x,[])
        y = sum(x,flag)/0;
        return
    end
    
    dim = find(size(x)~=1,1);
    if isempty(dim), dim = 1; end
end

if ~isobject(x) && isinteger(x) 
    isnative = strcmp(flag,'native');
    if intmin(class(x)) == 0  % unsigned integers
        y = sum(x,dim,flag);
        if (isnative && all(y(:) < intmax(class(x)))) || ...
                (~isnative && all(y(:) <= flintmax))
            % no precision lost, can use the sum result
            y = y/size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,flag);
        end
    else  % signed integers
        ypos = sum(max(x,0),dim,flag);
        yneg = sum(min(x,0),dim,flag);
        if (isnative && all(ypos(:) < intmax(class(x))) && ...
                all(yneg(:) > intmin(class(x)))) || ...
                (~isnative && all(ypos(:) <= flintmax) && ...
                all(yneg(:) >= -flintmax))
            % no precision lost, can use the sum result
            y = (ypos+yneg)/size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,flag);    
        end
    end
else
    y = sum(x,dim,flag)/size(x,dim);
end
    
end


function y = intmean(x, dim, flag)
% compute the mean of integer vector

if strcmp(flag, 'native')
    doubleoutput = false;
else 
    assert(strcmp(flag,'double') || strcmp(flag,'default'));
    doubleoutput = true;
end

shift = [dim:ndims(x),1:dim-1];
x = permute(x,shift);

xclass = class(x);
if doubleoutput
    outclass = 'double';
else
    outclass = xclass;
end

if intmin(xclass) == 0
    accumclass = 'uint64';
else
    accumclass = 'int64';
end
xsiz = size(x);
xlen = cast(xsiz(1),accumclass);

y = zeros([1 xsiz(2:end)],outclass);
ncolumns = prod(xsiz(2:end));
int64input = isa(x,'uint64') || isa(x,'int64');

for iter = 1:ncolumns
    xcol = cast(x(:,iter),accumclass);
    if int64input
        xr = rem(xcol,xlen);
        ya = sum((xcol-xr)./xlen,1,'native');
        xcol = xr;
    else
        ya = zeros(accumclass);
    end
    xcs = cumsum(xcol);
    ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)) , 1);
    
    while (~isempty(ind))
        remain = rem(xcs(ind-1),xlen);
        ya = ya + (xcs(ind-1) - remain)./xlen;
        xcol = [remain; xcol(ind:end)];
        xcs = cumsum(xcol);
        ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)), 1);
    end
    
    if doubleoutput
        remain = rem(xcs(end),xlen);
        ya = ya + (xcs(end) - remain)./xlen;
        % The latter two conversions to double never lose precision as
        % values are less than FLINTMAX. The first conversion may lose
        % precision.
        y(iter) = double(ya) + double(remain)./double(xlen);
    else
        y(iter) = cast(ya + xcs(end) ./ xlen, outclass);
    end
end
y = ipermute(y,shift);

end
