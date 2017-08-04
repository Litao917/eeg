%BITCMP Complement bits.
%   C = BITCMP(A) returns the bitwise complement of A, where A is a signed or
%   unsigned integer array. A can also be a double array containing 
%   non-negative integer elements less than or equal to 
%   intmax('uint64'), where BITCMP returns their 64-bit unsigned complements.
%
%   C = BITCMP(A,ASSUMEDTYPE) assumes A is of type ASSUMEDTYPE. If A is a 
%   double array, then ASSUMEDTYPE can be 'int8', 'uint8', 'int16', 'uint16',
%   'int32', 'uint32', 'int64', or 'uint64' (the default). For example, 
%   BITCMP(A,'int8') is equivalent to double(BITCMP(int8(A))). All elements i
%   in A must have integer values within the range of ASSUMEDTYPE.
%   If A is of an integer type, then ASSUMEDTYPE must be this type.
%
%   C = BITCMP(A,N) will not accept N in a future release. Use 
%   BITCMP(A,ASSUMEDTYPE) instead. Returns the bitwise complement of A as an 
%   N-bit unsigned integer. A may not have any bits sets higher than N, i.e. 
%   may not have value greater than 2^N-1. The largest value of N is the 
%   number of bits in the unsigned integer class of A, e.g., the largest 
%   value for UINT32s is N=32.
%
%   Example:
%      a = bitcmp(64,'uint8');
%
%   See also BITAND, BITOR, BITXOR, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2012 The MathWorks, Inc.

