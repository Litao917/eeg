%~= (NE)   Not equal relation for handles.
%   Handles are equal if they are handles for the same object and are 
%   unequal otherwise.
%
%   H1 ~= H2 performs element-wise comparisons between handle arrays H1 
%   and H2.  H1 and H2 must be of the same dimensions unless one is a 
%   scalar.  The result is a logical array of the same dimensions, where 
%   each element is an element-wise equality result.
%
%   If one of H1 or H2 is scalar, scalar expansion is performed and the 
%   result will match the dimensions of the array that is not scalar.
%
%   TF = NE(H1, H2) stores the result in a logical array of the same
%   dimensions.
%
%   See also HANDLE, HANDLE/EQ, HANDLE/GE, HANDLE/GT, HANDLE/LE, HANDLE/LT
 
%   Copyright 2007 The MathWorks, Inc.
%   Built-in function.



