%ISREAL True for real array.
%   ISREAL(X) returns 1 if X does not have an imaginary part
%   and 0 otherwise.
%
%   ~ISREAL(X) detects arrays that have an imaginary part even if
%   it is all zero.
%   ~ANY(IMAG(X(:))) detects strictly real arrays, whether X has
%   an all zero imaginary part allocated or not.
%
%   Example:
%      x = magic(3);
%      y = complex(x);
%   In this example, isreal(x) returns true. isreal(y) returns
%   false, because COMPLEX returns y with an all zero imaginary
%   part. 
%
%   See also REAL, IMAG, COMPLEX, I, J.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

