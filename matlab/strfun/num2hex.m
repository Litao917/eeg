function S = num2hex(X)
%NUM2HEX Convert singles and doubles to IEEE hexadecimal strings.
%   If X is a single or double precision array with n elements,
%   NUM2HEX(X) is an n-by-8 or n-by-16 char array of the hexadecimal
%   floating point representation.  The same representation is printed
%   with FORMAT HEX.
%
%   Examples:
%
%      num2hex([1 0 0.1 -pi Inf]) is
%      3ff0000000000000
%      0000000000000000
%      3fb999999999999a
%      c00921fb54442d18
%      7ff0000000000000
%
%      num2hex(single([1 0 0.1 -pi Inf])) is
%      3f800000
%      00000000
%      3dcccccd
%      c0490fdb
%      7f800000
%
%   See also HEX2NUM, DEC2HEX, FORMAT.

%   Copyright 1984-2012 The MathWorks, Inc.
narginchk(1,1);
if ~isreal(X)
    error(message('MATLAB:num2hex:realInput'))
end
if ~isfloat(X)
    error(message('MATLAB:num2hex:floatpointInput', class( X )))
end
if isa(X,'double')
    width = 16;
else
    width = 8;
end
N = typecast(X(end:-1:1),'uint8');
S = reshape(sprintf('%02x',N(end:-1:1)),width,numel(X))';
