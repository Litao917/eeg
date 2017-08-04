function [L,exitflag] = logm(A)
%LOGM   Matrix logarithm.
%   L = LOGM(A) is the principal matrix logarithm of A, the inverse of EXPM(A).
%   L is the unique logarithm for which every eigenvalue has imaginary part
%   lying strictly between -PI and PI.  If A is singular or has any eigenvalues
%   on the negative real axis, then the principal logarithm is undefined,
%   a non-principal logarithm is computed, and a warning message is printed.
%
%   [L,EXITFLAG] = LOGM(A) returns a scalar EXITFLAG that describes
%   the exit condition of LOGM:
%   EXITFLAG = 0: successful completion of algorithm.
%   EXITFLAG = 1: too many matrix square roots needed.
%                 Computed L may still be accurate, however.
%
%   Class support for input A:
%      float: double, single
%
%   See also EXPM, SQRTM, FUNM.

%   Nicholas J. Higham
%   Copyright 1984-2012 The MathWorks, Inc. 

if nargout < 2   
    L = funm(A,@log);  
else
    [L,exitflag] = funm(A,@log);
end
